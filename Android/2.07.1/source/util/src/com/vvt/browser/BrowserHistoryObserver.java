package com.vvt.browser;

import java.util.HashSet;

import android.content.Context;
import android.net.Uri;
import android.provider.Browser;

import com.vvt.content.IContentObserver;
import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public class BrowserHistoryObserver {
	
	private static final String TAG = "UrlObserver";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	private HashSet<OnBrowserHistoryChangeListener> mListeners;
	private WorkerObserver mObserver;
	
	public BrowserHistoryObserver(Context context) {
		mContext = context;
		mListeners = new HashSet<BrowserHistoryObserver.OnBrowserHistoryChangeListener>();
	}

	public void register(OnBrowserHistoryChangeListener listener) {
		boolean isAdded = mListeners.add(listener);
		
		if (isAdded) {
			if (LOGV) FxLog.v(TAG, "register # New listener is registered");
			
			if (mObserver == null) {
				mObserver = new WorkerObserver(mContext);
			}
			
			if (! mObserver.isEnabled()) {
				mObserver.enable();
				if (LOGV) FxLog.v(TAG, "register # Observer is enabled");
			}
		}
		else {
			if (LOGV) FxLog.v(TAG, "register # listener is duplicated!");
		}
	}
	
	public void unregister(OnBrowserHistoryChangeListener listener) {
		boolean isRemoved = mListeners.remove(listener);
		
		if (isRemoved) {
			if (LOGV) FxLog.v(TAG, "unregister # Listener is removed");
			if (mListeners.isEmpty()) {
				if (LOGV) FxLog.v(TAG, "unregister # No listener left");
				mObserver.disable();
				if (LOGV) FxLog.v(TAG, "unregister # Observer is disabled");
			}
		}
		else {
			if (LOGV) FxLog.v(TAG, "unregister # Listener not found");
		}
	}
	
	private void notifyListener() {
		for (OnBrowserHistoryChangeListener listener : mListeners) {
			listener.onBrowserHistoryChange();
		}
	}
	
	public interface OnBrowserHistoryChangeListener {
		public void onBrowserHistoryChange();
	}
	
	private class WorkerObserver extends IContentObserver {

		public WorkerObserver(Context context) {
			super(context);
		}

		@Override
		protected Uri getContentUri() {
			return Browser.BOOKMARKS_URI;
		}

		@Override
		protected String getTag() {
			return TAG;
		}

		@Override
		protected void onContentChange() {
			notifyListener();
		}
	
	}
	
}
