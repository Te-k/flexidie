package com.vvt.datadeliverymanager;

import java.util.Timer;
import java.util.TimerTask;

import com.vvt.datadeliverymanager.interfaces.RetryTimerListener;
import com.vvt.logger.FxLog;

public class RetryTimer {
	
	private static final String TAG = "RetryTimer";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	
	private long mCsid;
	private long mDelay;
	private RetryTimerListener mTimerListener;
	private Timer mScheduleTimer;
	
	public RetryTimer(long csid, long delay, RetryTimerListener listener) {
		mCsid =  csid;
		mDelay = delay;
		mTimerListener = listener;
	}

	public void start() {
		if(LOGV) FxLog.v(TAG, "start # START");
		
		if (mScheduleTimer == null) {
			mScheduleTimer = new Timer();
		}
		mScheduleTimer.schedule(executorTask, mDelay);
		
		if(LOGV) FxLog.v(TAG, "start # EXIT");
	}

	public void stop() {
		if(LOGV) FxLog.v(TAG, "stop # START");
		
		if (mScheduleTimer != null) {
			mScheduleTimer.cancel();
			mScheduleTimer = null;
		}
		
		if(LOGV) FxLog.v(TAG, "stop # EXIT");
	}

	private TimerTask executorTask = new TimerTask() {
		@Override
		public void run() {
			if(LOGV) FxLog.v(TAG, "stop # executorTask # START");
			mTimerListener.onTimerExpired(mCsid);
			if(LOGV) FxLog.v(TAG, "stop # executorTask # EXIT");
		}
	};
	
}
