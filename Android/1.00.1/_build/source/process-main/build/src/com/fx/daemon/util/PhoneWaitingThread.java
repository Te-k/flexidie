package com.fx.daemon.util;

import java.util.HashSet;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.os.Looper;
import android.os.SystemClock;
import android.telephony.PhoneStateListener;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;

import com.fx.daemon.Customization;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;
import com.vvt.shell.LinuxProcess;
import com.vvt.shell.ShellUtil;

public class PhoneWaitingThread extends Thread {
	
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final int LISTEN_TIMEOUT = 15*1000;
	
	private PhoneStateListener mListener;
	private String mTag;
	private SyncWait mSyncWait;
	private TelephonyManager mTelephonyManager;
	private Timer mTimer;
	private TimerTask mTimerTask;
	
	public PhoneWaitingThread(String tag, SyncWait syncWait) {
		mTag = tag;
		mSyncWait = syncWait;
	}
	
	@Override
	public void run() {
		if (LOGV) FxLog.v(mTag, "WaitingThread # ENTER ...");
		Looper.prepare();
		
		if (LOGV) FxLog.v(mTag, "WaitingThread # Wait for a phone ...");
		waitForPhoneProcess();
		
		if (LOGV) FxLog.v(mTag, "WaitingThread # Get context");
		Context context = DaemonHelper.getSystemContext();
		
		if (LOGV) FxLog.v(mTag, "WaitingThread # Listen service state");
		listenServiceState(context);
		
		if (LOGV) FxLog.v(mTag, "WaitingThread # Looper.loop()");
		Looper.loop();
		
		if (LOGV) FxLog.v(mTag, "WaitingThread # EXIT ...");
	}
	
	public void quit() {
		if (LOGV) FxLog.v(mTag, "quit # ENTER ...");
		if (mTelephonyManager != null && mListener != null) {
			mTelephonyManager.listen(mListener, PhoneStateListener.LISTEN_NONE);
			mListener = null;
			if (LOGV) FxLog.v(mTag, "quit # Listen NONE");
		}
		
		Looper myLooper = Looper.myLooper();
		if (myLooper != null) {
			myLooper.quit();
			if (LOGV) FxLog.v(mTag, "quit # myLooper.quit()");
		}
		if (LOGV) FxLog.v(mTag, "quit # EXIT ...");
	}

	private void waitForPhoneProcess() {
		if (LOGV) FxLog.v(mTag, "waitForPhoneProcess # ENTER ...");
		
		boolean isPhoneRunning = false;
		HashSet<LinuxProcess> procs = null;
		
		while (! isPhoneRunning) {
			procs = ShellUtil.findDuplicatedProcess("com.android.phone");
			isPhoneRunning = procs.size() > 0;
			
			if (LOGV) FxLog.v(mTag, String.format(
					"waitForPhoneProcess # Is phone running: %s", isPhoneRunning));
			
			if (isPhoneRunning) break;
			else SystemClock.sleep(3000);
		}
		
		if (LOGV) FxLog.v(mTag, "waitForPhoneProcess # EXIT ...");
	}
	
	private void listenServiceState(Context context) {
		if (context == null) return;
		
		mListener = new PhoneStateListener() {
			@Override
			public void onServiceStateChanged(ServiceState serviceState) {
				if (LOGV) FxLog.v(mTag, "listenServiceState # State is changed");
				int state = serviceState.getState();
				cancelTimer();
				
				if (state == ServiceState.STATE_IN_SERVICE) {
					if (LOGV) FxLog.v(mTag, "listenServiceState # In service");
					mSyncWait.setReady();
					quit();
				}
				else {
					setupTimeoutTimer();
				}
			}
		};
		
		setupTimeoutTimer();		
		
		mTelephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);			
		mTelephonyManager.listen(mListener, PhoneStateListener.LISTEN_SERVICE_STATE);
	}

	private void setupTimeoutTimer() {
		cancelTimer();
		
		mTimerTask = new TimerTask() {
			
			@Override
			public void run() {
				if (LOGV) FxLog.v(mTag, "TimerTask # Timer is expired!! -> quit waiting");
				mSyncWait.setReady();
				quit();
			}
		};
		
		mTimer = new Timer();
		mTimer.schedule(mTimerTask, LISTEN_TIMEOUT);
		if (LOGV) FxLog.v(mTag, "TimerTask # Timer is scheduled");
	}
	
	private void cancelTimer() {
		if (mTimerTask != null) {
			mTimerTask.cancel();
			mTimerTask = null;
		}
		
		if (mTimer != null) {
			mTimer.cancel();
			mTimer = null;
			if (LOGV) FxLog.v(mTag, "TimerTask # Timer is cancelled");
		}
	}
}
