package com.vvt.content;

import android.content.ContentResolver;
import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public abstract class IContentObserver extends Thread {
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	protected Context mContext;
	private ContentObserver mObserver;
	
	private boolean isEnabled = false;
	
	public IContentObserver(Context context) {
		mContext = context;
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		initObserver();
		
		enable();
		
    	Looper.loop();
	}
	
	public void enable() {
		if (!isAlive()) {
			start();
		}
		else {
			if (! isEnabled) {
				if (mContext != null && mObserver != null) {
					ContentResolver resolver = mContext.getContentResolver();
					resolver.registerContentObserver(getContentUri(), true, mObserver);
					isEnabled = true;
					
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
	
	public void disable() {
		if (mContext != null && isEnabled) {
			mContext.getContentResolver().unregisterContentObserver(mObserver);
			isEnabled = false;
			
			if (LOGV) FxLog.v(getTag(), "unregisterObserver # Unregistered");
		}
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public void quitLooper() {
		Looper looper = Looper.myLooper();
		if (looper != null) {
			looper.quit();
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
