package com.vvt.remotecommandmanager;


import com.vvt.remotecommandmanager.processor.keywordlist.AddKeywordProcessorTestCase;

import junit.framework.TestSuite;
import android.test.InstrumentationTestRunner;
import android.test.InstrumentationTestSuite;

 
public class MyInstrumentationTestRunner extends InstrumentationTestRunner {
	@Override
	public TestSuite getAllTests() {
		InstrumentationTestSuite suite = new InstrumentationTestSuite(this);
		//suite.addTestSuite(DDMFunctionalTestCase.class);
		/*suite.addTestSuite(RemoteCommandManagerTestCase.class);*/
		
		suite.addTestSuite(AddKeywordProcessorTestCase.class);
 		return suite;
	}
	
	@Override
	public ClassLoader getLoader()
	{
		return MyInstrumentationTestRunner.class.getClassLoader();
	}
}