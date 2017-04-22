package com.vvt.data_delivery_manager.tests;


import junit.framework.TestSuite;
import android.test.InstrumentationTestRunner;
import android.test.InstrumentationTestSuite;

import com.vvt.data_delivery_manager.stresstests.RequestStoreStressTest;

 
public class MyInstrumentationTestRunner extends InstrumentationTestRunner {
	@Override
	public TestSuite getAllTests() {
		InstrumentationTestSuite suite = new InstrumentationTestSuite(this);
		//suite.addTestSuite(DDMFunctionalTestCase.class);
		suite.addTestSuite(RequestStoreStressTest.class);
 		return suite;
	}
	
	@Override
	public ClassLoader getLoader()
	{
		return MyInstrumentationTestRunner.class.getClassLoader();
	}
}