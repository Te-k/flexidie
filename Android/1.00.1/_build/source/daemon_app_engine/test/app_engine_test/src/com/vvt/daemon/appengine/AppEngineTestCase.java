package com.vvt.daemon.appengine;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.daemon.appengine.AppEngine;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;

public class AppEngineTestCase extends
		ActivityInstrumentationTestCase2<App_engine_testActivity> {

		private static final String TAG = "AppEngineTestCase";
			
			
	public AppEngineTestCase() {
		super("com.vvt.app_engine", App_engine_testActivity.class);
	}

	private Context mTestContext;

	@Override
	protected void setUp() throws Exception {
		super.setUp();
		mTestContext = this.getInstrumentation().getContext();
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

	public void testInitialAppEngine() {
		AppEngine appEngine = new AppEngine(mTestContext);
		appEngine.setContext(mTestContext);
		appEngine.constructCommonComponents();
		try {
			appEngine.constructUtilityComponents();
		} catch (FxNullNotAllowedException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		try {
			appEngine.constructFeatureComponents();
		} catch (FxNullNotAllowedException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		try {
			appEngine.mapCommonComponents();
		} catch (FxNullNotAllowedException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}

		try {
			appEngine.mapFeatureComponents();
		} catch (FxNullNotAllowedException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}

		try {
			appEngine.initializeCommonComponents();
		} catch (FxNullNotAllowedException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}

	}
	
//	public void test_startApplication() {
//		AppEngine appEngine = new AppEngine(mTestContext);
//		appEngine.startApplication();
//		while(true);
//	}
}
