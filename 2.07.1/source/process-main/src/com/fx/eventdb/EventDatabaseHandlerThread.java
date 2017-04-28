package com.fx.eventdb;

import android.os.Handler;
import android.os.Looper;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class EventDatabaseHandlerThread extends Thread {
	
	private static final String TAG = "EventDatabaseHandlerThread";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	private static EventDatabaseHandlerThread sInstance;
	private Handler mHandler;
	
	public static EventDatabaseHandlerThread getInstance() {
		if (sInstance == null) {
			sInstance = new EventDatabaseHandlerThread();
		}
		return sInstance;
	}
	
	private EventDatabaseHandlerThread() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "EventDatabaseHandlerThread # ENTER ...");
		}
	}
	
	@Override
	public void run() {
		Looper.prepare();
		mHandler = new Handler();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("run # mHandler: %s is created", mHandler));
		}
		
		Looper.loop();
	}
	
	public void post(Runnable r) {
		if (mHandler != null && r != null) {
			// Add delayed for better synchronize
			// It is hard to manage when the process is finished too fast
			mHandler.postDelayed(r, 100);
		}
	}
	
}
