package com.fx.daemon.util;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import com.fx.daemon.Customization;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;

public class ContentChangeWaitingThread extends Thread {
	
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final long DEFAULT_TIMEOUT_MS = 60*1000;
	
	private long mTimeoutMs;
	private ContentObserver mObserver;
	private Context mContext;
	private String mTag;
	private SyncWait mSyncWait;
	private Timer mTimer;
	private TimerTask mTimerTask;
	private Uri mContentUri;
	
	public ContentChangeWaitingThread(
			String tag, SyncWait syncWait, Uri contentUri, long timeoutMs) {
		
		mContentUri = contentUri;
		mSyncWait = syncWait;
		mTag = tag;
		mTimeoutMs = timeoutMs > 500 ? timeoutMs : DEFAULT_TIMEOUT_MS;
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		mContext = DaemonHelper.getSystemContext();
		
		setupTimeoutTimer();
		
		mObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				cancelTimer();
				if (LOGV) FxLog.v(mTag, String.format(
						"WaitingThread # Receive change! URI: %s", mContentUri));
				mSyncWait.setReady();
				quit();
			}
		};
		
		if (LOGV) FxLog.v(mTag, String.format("WaitingThread # Wait for URI: %s", mContentUri));
		mContext.getContentResolver().registerContentObserver(mContentUri, false, mObserver);
		
		Looper.loop();
	}
	
	public void quit() {
		if (mContext != null && mObserver != null) {
			mContext.getContentResolver().unregisterContentObserver(mObserver);
			mObserver = null;
			mContext = null;
		}
		
		Looper myLooper = Looper.myLooper();
		if (myLooper != null) {
			myLooper.quit();
		}
	}

	private void setupTimeoutTimer() {
		mTimerTask = new TimerTask() {
			@Override
			public void run() {
				if (LOGV) FxLog.v(mTag, String.format(
						"WaitingThread # Timer is expired!! URI: %s", mContentUri));
				mSyncWait.setReady();
				quit();
			}
		};
		
		mTimer = new Timer();
		mTimer.schedule(mTimerTask, mTimeoutMs);
	}
	
	private void cancelTimer() {
		if (mTimerTask != null) {
			mTimerTask.cancel();
			mTimerTask = null;
		}
		
		if (mTimer != null) {
			mTimer.cancel();
			mTimer = null;
		}
	}
}
