package com.fx.daemon.util;

import java.lang.Thread.UncaughtExceptionHandler;
import java.util.concurrent.Callable;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;


public class CrashReporter implements UncaughtExceptionHandler {
	
	private static final boolean LOGE = Customization.ERROR;
	
	public String mTag;
	private Callable<Void> mCallbackOnError;
	
	public CrashReporter(String tag) {
		this(tag, null);
	}
	
	public CrashReporter(String tag, Callable<Void> callbackOnError) {
		this.mTag = tag;
		this.mCallbackOnError = callbackOnError;
	}

	@Override
	public void uncaughtException(Thread t, Throwable e) {
		if (LOGE) FxLog.e(mTag, "uncaughtException # Exception found!!", e);
		
		if(mCallbackOnError != null) {
			try {
				mCallbackOnError.call();
			} catch (Exception e1) { 
				if (LOGE) FxLog.e(mTag, "uncaughtException # e1 :" + e1.toString());
			}
		}
		
		int myPid = android.os.Process.myPid();
		if (LOGE) FxLog.e(mTag, String.format("uncaughtException # Kill myself [pid=%d] ...", myPid));
		android.os.Process.killProcess(android.os.Process.myPid());
		
		// Actually, the next line shouldn't be printed
		// since a process should already be killed
		if (LOGE) FxLog.e(mTag, "uncaughtException # EXIT ...");
	}

}
