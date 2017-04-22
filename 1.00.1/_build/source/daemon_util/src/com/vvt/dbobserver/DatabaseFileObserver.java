package com.vvt.dbobserver;

import android.os.FileObserver;
import android.os.SystemClock;

import com.vvt.daemon.util.Customization;
import com.vvt.logger.FxLog;

public abstract class DatabaseFileObserver extends FileObserver {

	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "DatabaseFileObserver";
	private static final boolean LOGV = Customization.VERBOSE;
	
	/*============================ MEMBER ================================*/
	private long mSleepMs = 2000;
	
	/*============================ METHOD ================================*/
	
	public DatabaseFileObserver(String path) {
		super(path);
	}
	
	public void setSleep(long sleepMs) {
		mSleepMs = sleepMs;
	}

	@Override
	public void onEvent(int event, String path) {
		
		if (event == FileObserver.MODIFY) {
			
			if (LOGV) FxLog.v(TAG,"onEvent # Stop watching");
			stopWatching();

			Thread t = new Thread(new Runnable() {
			
				@Override
				public void run() {
					if (LOGV) FxLog.v(TAG, String.format(
							"onEvent # Sleep %d sec", mSleepMs / 1000));
					
					SystemClock.sleep(mSleepMs);
					
					if (LOGV) FxLog.v(TAG, "onEvent # Start watching again");
					startWatching();
					
					onEventNotify();
				}
			});
			t.start();
		}
	}
	
	public abstract void onEventNotify();
	
}


