package com.fx.eventdb;

import android.content.Context;

public abstract class EventQueue implements Runnable {
	
	protected Context mContext;
	protected EventDatabaseManager mEventdbManager;
	protected EventDatabaseHelper mEventdbHelper;
	protected Callback mCallback;
	
	public EventQueue(Context context, Callback callback) {
		mContext = context;
		mEventdbManager = EventDatabaseManager.getInstance(mContext);
		mEventdbHelper = EventDatabaseHelper.getInstance();
		mCallback = callback;
	}
	
	protected void notifyProcessDone() {
		if (mCallback != null) {
			mCallback.onProcessDone();
		}
	}

	public interface Callback {
		public void onProcessDone();
	}
}
