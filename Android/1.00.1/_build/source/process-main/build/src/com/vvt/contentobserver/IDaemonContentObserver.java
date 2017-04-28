package com.vvt.contentobserver;

import android.content.ContentResolver;
import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import com.vvt.daemon.util.Customization;
import com.vvt.logger.FxLog;

public abstract class IDaemonContentObserver extends Thread {
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	protected Context mContext;
	private ContentObserver mObserver;
	
	private boolean isRegistered = false;
	
	public IDaemonContentObserver(Context context) {
		mContext = context;
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		initObserver();
		
		registerObserver();
		
    	Looper.loop();
	}
	
	public void registerObserver() {
		if (!isAlive()) {
			start();
		}
		else {
			if (! isRegistered) {
				if (mContext != null && mObserver != null) {
					ContentResolver resolver = mContext.getContentResolver();
					resolver.registerContentObserver(getContentUri(), true, mObserver);
					isRegistered = true;
					
					if (LOGV) FxLog.v(getTag(), "registerObserver # Registered");
				}
				else {
					if (LOGE) FxLog.e(getTag(), String.format(
							"registerObserver # Failed!! mContext=%s, mObserver=%s", 
							mContext, mObserver));
					
					throw new RuntimeException("Observer registration failed!!");
				}
			}
		}
	}
	
	public void unregisterObserver() {
		if (mContext != null && isRegistered) {
			mContext.getContentResolver().unregisterContentObserver(mObserver);
			isRegistered = false;
			
			if (LOGV) FxLog.v(getTag(), "unregisterObserver # Unregistered");
		}
	}
	
	/**
	 * This method must be invoked inside a Thread that call Looper.prepare().
	 */
	private void initObserver() {
		mObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				onContentChange();
			}
		};
	}
	
	protected abstract Uri getContentUri();
	protected abstract String getTag();
	protected abstract void onContentChange();
	
}
