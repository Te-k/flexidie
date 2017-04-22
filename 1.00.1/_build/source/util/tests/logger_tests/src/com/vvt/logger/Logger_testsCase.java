package com.vvt.logger;

import java.io.File;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

public class Logger_testsCase extends ActivityInstrumentationTestCase2<Logger_testsActivity>{

	private static final String TAG = "Logger_testsCase";
	private Context mTestContext;
	private Logger mLogger;
	
	
	public Logger_testsCase() {
		super("com.vvt.logger", Logger_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();
		mTestContext = this.getInstrumentation().getContext();
		mLogger = Logger.getInstance();
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}

	public Context getTestContext() {
		return mTestContext;
	}
	
	@SuppressWarnings("unused")
	public void test_printLog() {
		
		//mLogger.SetLogPath("/sdcard/printLog/", "log.txt");
		
		mLogger.enableDebugLog();
		mLogger.enableErrorLog();
		
		FxLog.v(TAG, "test log.v");
		FxLog.d(TAG, "test log.d");
		FxLog.i(TAG, "test log.i");
		FxLog.w(TAG, "test log.w");
		FxLog.e(TAG, "test log.e");
		
		String path = null;
		try {
		File file = new File(path);
		} catch (Exception e) {
			FxLog.e(TAG, "test log.e", e);
		}
		
		mLogger.disableRuntimeLog();
		mLogger.disableDebugLog();
		mLogger.disableErrorLog();
		
		FxLog.v(TAG, "test log.v");
		FxLog.d(TAG, "test log.d");
		FxLog.i(TAG, "test log.i");
		FxLog.w(TAG, "test log.w");
		FxLog.e(TAG, "test log.e");
		
		try {
		File file = new File(path);
		} catch (Exception e) {
			FxLog.e(TAG, "test log.e", e);
		}
		
		
	}
	
	@SuppressWarnings("unused")
	public void test_changeLogPath() {
		
		mLogger.SetLogPath("/sdcard/change/", "log.txt");
		
		String path = null;
		try {
		File file = new File(path);
		} catch (Exception e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		
		mLogger.enableDebugLog();
		
		mLogger.SetLogPath("/sdcard/changeLog", "log.txt");
		
		FxLog.d(TAG, "test log.d");
	}
	
}
