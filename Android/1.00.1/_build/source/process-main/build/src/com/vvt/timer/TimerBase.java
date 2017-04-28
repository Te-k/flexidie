package com.vvt.timer;

import android.os.Handler;

import com.vvt.logger.FxLog;

/**
 * This implementation of timer is more proper for Android than the standard Java Timer.
 * See http://android-developers.blogspot.com/2007/11/stitch-in-time.html 
 */
public abstract class TimerBase {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	private static final String TAG = "TimerBase";
	private static final boolean LOGV = false;
	
	private boolean mRunning = false;
	private long mTimerDurationMs = 0;
	
	private Handler mHandler = new Handler(); 
	
	private Runnable mRunnable = new Runnable() {

		public void run() {
			if (mRunning) {
				long aStartTime = System.currentTimeMillis();
				startTask();
				long aEndTime = System.currentTimeMillis();
				long aDelayTime = mTimerDurationMs - (aEndTime - aStartTime);
				mHandler.postDelayed(mRunnable, aDelayTime >= 0 ? aDelayTime : 0);
			}
		}
	};
	
	private void startTask() {
		Thread aThread = new Thread() {
			public void run() {
				onTimer();
			}
		};
		aThread.start();
	}

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	/**
	 * If the timer duration is set to be less than this method execution duration, 
	 * the actual running interval will be equal to the method execution time. 
	 */
	public abstract void onTimer();
	
	public TimerBase() {
		
	}
	
	public long getTimerDurationMs() {
		return mTimerDurationMs;
	}
	
	public void setTimerDurationMs(long aTimerDurationMilliseconds) {
		mTimerDurationMs = aTimerDurationMilliseconds;
	}
	
	public void start() {
		if (LOGV) {
			FxLog.v(TAG, "start # ENTER ...");
		}
		
		if (! mRunning) {
			if (LOGV) {
				FxLog.v(TAG, "post callbacks");
			}
			
			mRunning = true;
			mHandler.postDelayed(mRunnable, 
					mTimerDurationMs > 0 ? mTimerDurationMs : 0);
		}
	}
	
	public void stop() {
		if (LOGV) {
			FxLog.v(TAG, "stop # ENTER ...");
		}
		
		if (mRunning) {
			if (LOGV) {
				FxLog.v(TAG, "removing callbacks");
			}
			
			mRunning = false;
			mHandler.removeCallbacks(mRunnable);
		}
	}
	
}
