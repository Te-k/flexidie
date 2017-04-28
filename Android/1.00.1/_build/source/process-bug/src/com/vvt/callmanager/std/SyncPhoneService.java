package com.vvt.callmanager.std;

import com.vvt.callmanager.ref.Customization;
import com.vvt.logger.FxLog;

class SyncPhoneService {
	
	private static final String TAG = "SyncPhoneService";
	private static final boolean LOGV = Customization.VERBOSE;

	private boolean mIsActive;
	private boolean mEmpty = true;
	
	public synchronized boolean getState() {
		while (mEmpty) {
			try {
				if (LOGV) FxLog.v(TAG, "getState # Wait ...");
				wait();
				if (LOGV) FxLog.v(TAG, "getState # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		mEmpty = true;
		notifyAll();
		
		if (LOGV) FxLog.v(TAG, String.format("getState # mIsActive: %s", mIsActive));
		return mIsActive;
	}
	
	public synchronized void setState(boolean state) {
		while (!mEmpty) {
			try {
				if (LOGV) FxLog.v(TAG, "setState # Wait ...");
				wait();
				if (LOGV) FxLog.v(TAG, "setState # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		mEmpty = false;
		mIsActive = state;
		if (LOGV) FxLog.v(TAG, String.format("setState # state: %s", state));
		notifyAll();
	}
	
}
