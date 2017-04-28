package com.vvt.shell;

import android.util.Log;


public class PromptWait {
	
	private static final String TAG = "SyncWait";
	private static final boolean LOGV = Customization.SHELL_DEBUG ;
	
	private boolean mToggle = true;
	private String mPromptRead;
	
	/**
	 * Call this method to make the caller wait
	 */
	public synchronized void getReady() {
		while (mToggle) {
			try {
				if (LOGV) Log.v(TAG, "getReady # Wait ...");
				wait();
				if (LOGV) Log.v(TAG, "getReady # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		if (LOGV) Log.v(TAG, "getReady # Notify all");
		
		mToggle = true;
		notifyAll();
	}
	
	/**
	 * This method should be call by the worker thread to notify the caller thread
	 */
	public synchronized void setReady() {
		while (!mToggle) {
			try {
				if (LOGV) Log.v(TAG, "setReady # Wait ...");
				wait();
				if (LOGV) Log.v(TAG, "setReady # Get notified");
			}
			catch (InterruptedException e) { /* ignore */ }
		}
		
		if (LOGV) Log.v(TAG, "setReady # Notify all");
		
		mToggle = false;
		notifyAll();
	}

	public String getPromptRead() {
		return mPromptRead;
	}

	public void setPromptRead(String promptRead) {
		this.mPromptRead = promptRead;
	}
	
}
