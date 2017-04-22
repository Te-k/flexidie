package com.vvt.connection_history_manager_testapp.tests;

import junit.framework.TestSuite;
import android.test.InstrumentationTestRunner;
import android.test.InstrumentationTestSuite;

public class MyInstrumentationTestRunner extends InstrumentationTestRunner {
	@Override
	public TestSuite getAllTests() {
		InstrumentationTestSuite suite = new InstrumentationTestSuite(this);
		suite.addTestSuite(ConnectionHistoryManagerTestCase.class);
		return suite;
	}

	@Override
	public ClassLoader getLoader() {
		return MyInstrumentationTestRunner.class.getClassLoader();
	}
}
