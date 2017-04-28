package com.fx.daemon.util;

import java.lang.Thread.UncaughtExceptionHandler;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;


public class CrashReporter implements UncaughtExceptionHandler {
	
	private static final boolean LOGE = Customization.ERROR;
	
	public String mTag;
	
	public CrashReporter(String tag) {
		mTag = tag;
	}

	@Override
	public void uncaughtException(Thread t, Throwable e) {
		if (LOGE) FxLog.e(mTag, "uncaughtException # Exception found!!", e);
		
		int myPid = android.os.Process.myPid();
		if (LOGE) FxLog.e(mTag, String.format("uncaughtException # Kill myself [pid=%d] ...", myPid));
		android.os.Process.killProcess(android.os.Process.myPid());
		
		// Actually, the next line shouldn't be printed
		// since a process should already be killed
		if (LOGE) FxLog.e(mTag, "uncaughtException # EXIT ...");
	}

}
