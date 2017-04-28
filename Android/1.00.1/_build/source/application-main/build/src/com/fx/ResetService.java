package com.fx;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import com.fx.daemon.DaemonHelper;
import com.fx.maind.ref.MainDaemon;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.util.Customization;
import com.fx.util.FxResource;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.daemon.appengine.AppEnginDaemonResource;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class ResetService extends Service {
	
	private static final String TAG = "ResetService";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	private boolean mIsRunning = false;
	
	private Handler mHandler;
	private IBinder mBinder = new LocalBinder();
	private TimerBase mProcessingTimeout;
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// flags: 0=Default, 1=START_FLAG_REDELIVERY, 2=START_FLAG_RETRY
		if (intent != null) {
			RunningThread t = new RunningThread();
			t.start();
		}
		return START_NOT_STICKY;
	}
	
	public static void cleanupDevice() throws CannotGetRootShellException {
		MainDaemon mainDaemon = new MainDaemon();
    	MonitorDaemon monitorDaemon = new MonitorDaemon();
		BugDaemon bugDaemon = new BugDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Remount system as read-write");
		ShellUtil.remountFileSystem(true);
		
		if (LOGV) FxLog.v(TAG, "run # Remove reboot hook");
		DaemonHelper.removeRebootHook();
		
		if (LOGV) FxLog.v(TAG, "run # Remove monitor daemon");
		monitorDaemon.removeNativeLibrary();
		monitorDaemon.removeDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Remove bug daemon");
		bugDaemon.removeNativeLibrary();
		bugDaemon.removeDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Remove main daemon");
		mainDaemon.removeNativeLibrary();
		mainDaemon.removeDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Remount system as read-only");
		ShellUtil.remountFileSystem(false);
		
		if (LOGV) FxLog.v(TAG, "run # Stop monitor daemon");
		monitorDaemon.stopDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Stop bug daemon");
		bugDaemon.stopDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Stop monitor daemon");
		mainDaemon.stopDaemon();
		
		if (LOGV) FxLog.v(TAG, "run # Clear AppEngin data");
		clearAppEnginData();
		
	}
	
	private static void clearAppEnginData() {
		if (LOGV) FxLog.v(TAG, "clearAppEnginData # ENTER ...");
		
		try {
			Shell rootShell = Shell.getRootShell();
			rootShell.exec(String.format("rm -r %s", AppEnginDaemonResource.APPENGIN_EXTRACTING_PATH));
		} catch (CannotGetRootShellException e) {
			FxLog.e(TAG, e.toString());
		}
		
		if (LOGV) FxLog.v(TAG, "clearAppEnginData # EXIT ...");
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
	
	public class LocalBinder extends Binder {
		public ResetService getService() {
			return ResetService.this;
		}
	}
	
	private class RunningThread extends Thread {
		@Override
		public void run() {
			if (LOGV) FxLog.v(TAG, "run # ENTER ...");
			
			setState(true);
			
			if (LOGV) FxLog.v(TAG, "run # Looper.prepare()");
			Looper.prepare();
			
			if (LOGV) FxLog.v(TAG, "run # Register timeout timer");
			resetProcessingTimeout();
			
			boolean isSuccess = false;
			
			try {
				if (LOGV) FxLog.v(TAG, "run # Check if device is perfectly rooted");
				if (ShellUtil.isDevicePerfectlyRooted(getApplicationContext())) {
					
					if (LOGV) FxLog.v(TAG, "run # Begine cleanup operation");
					cleanupDevice();
					
					isSuccess = true;
				}
			}
			catch (CannotGetRootShellException e) {
				if (LOGV) FxLog.v(TAG, "run # Getting root failed!!");
				isSuccess = false;
			}
			
			if (LOGV) FxLog.v(TAG, "run # Stop timeout timer");
			stopTimer();
			
			if (isSuccess) {
				if (LOGV) FxLog.v(TAG, "run # Cleanup operation success");
				notifyResetSuccess();
			}
			else {
				if (LOGV) FxLog.v(TAG, "run # Cleanup operation failed");
				notifyResetFailed();
			}
			
			setState(false);
			
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
	
	private void resetProcessingTimeout() {
    	stopTimer();
    	
    	if (mProcessingTimeout == null) {
	    	mProcessingTimeout = new TimerBase() {
				
				@Override
				public void onTimer() {
					if (LOGV) FxLog.v(TAG, "Time Out!!");
					if (LOGV) FxLog.v(TAG, "Cleanup operation failed");
					notifyResetFailed();
					
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
	
	private void notifyResetSuccess() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.resetView(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_RESET_SUCCESS);
	}
	private void notifyResetFailed() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.resetView(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_RESET_FAILED);
	}

}
