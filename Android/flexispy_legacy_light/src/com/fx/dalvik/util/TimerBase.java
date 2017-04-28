package com.fx.dalvik.util;

import com.fx.android.common.Customization;

import android.os.Handler;
import com.fx.dalvik.util.FxLog;

/**
 * This implementation of timer is more proper for Android than the standard Java Timer.
 * See http://android-developers.blogspot.com/2007/11/stitch-in-time.html 
 */
public abstract class TimerBase {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	private static final String TAG = "TimerBase";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private boolean running = false;
	
	private long timerDurationMilliseconds = 0;
	
	private Handler handler = new Handler(); 
	
	private Runnable runnable = new Runnable() {

		public void run() {
			if (running) {
				long aStartTime = System.currentTimeMillis();
				startTask();
				long aEndTime = System.currentTimeMillis();
				long aDelayTime = timerDurationMilliseconds - (aEndTime - aStartTime);
				handler.postDelayed(runnable, aDelayTime >= 0 ? aDelayTime : 0);
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
	
	public long getTimerDurationMilliseconds() {
		return timerDurationMilliseconds;
	}
	
	public void setTimerDurationMilliseconds(long aTimerDurationMilliseconds) {
		timerDurationMilliseconds = aTimerDurationMilliseconds;
	}
	
	public void start() {
		if (LOCAL_LOGV) FxLog.v(TAG, "start # ENTER ...");
		if (! running) {
			if (LOCAL_LOGV) FxLog.v(TAG, "post callbacks");
			running = true;
			handler.post(runnable);
		}
	}
	
	public void stop() {
		if (LOCAL_LOGV) FxLog.v(TAG, "stop # ENTER ...");
		if (running) {
			if (LOCAL_LOGV) FxLog.v(TAG, "removing callbacks");
			running = false;
			handler.removeCallbacks(runnable);
		}
	}
	
}
