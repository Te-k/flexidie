package com.fx.daemon.util;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

public class SyncWait {
	
	private static final String TAG = "SyncWait";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private boolean mToggle = true;
	
	/**
	 * Call this method to make the caller wait
	 */
	public synchronized void getReady() {
		while (mToggle) {
			try {
				if (LOGV) FxLog.v(TAG, "getReady # Wait ...");
				wait();
				if (LOGV) FxLog.v(TAG, "getReady # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		if (LOGV) FxLog.v(TAG, "getReady # Notify all");
		
		mToggle = true;
		notifyAll();
	}
	
	/**
	 * This method should be call by the worker thread to notify the caller thread
	 */
	public synchronized void setReady() {
		while (!mToggle) {
			try {
				if (LOGV) FxLog.v(TAG, "setReady # Wait ...");
				wait();
				if (LOGV) FxLog.v(TAG, "setReady # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		if (LOGV) FxLog.v(TAG, "setReady # Notify all");
		
		mToggle = false;
		notifyAll();
	}
	
}
