package com.vvt.eventrepository.tests;


import junit.framework.TestSuite;
import android.test.InstrumentationTestRunner;
import android.test.InstrumentationTestSuite;

 
public class MyInstrumentationTestRunner extends InstrumentationTestRunner {
	@Override
	public TestSuite getAllTests() {
		InstrumentationTestSuite suite = new InstrumentationTestSuite(this);
		suite.addTestSuite(FxFxDatabaseManagerTestCase.class);
		suite.addTestSuite(FxCallLogDaoTestCase.class);
		suite.addTestSuite(FxSmsDaoTestCase.class);
		suite.addTestSuite(FxMmsDaoTestCase.class);
		suite.addTestSuite(FxEmailDaoTestCase.class);
		suite.addTestSuite(FxLocationDaoTestCase.class);
		suite.addTestSuite(FxEventResultTestCase.class);
		suite.addTestSuite(FxCameraImageThumbnailTestCase.class);
		suite.addTestSuite(FxEventRepositoryManagerTestCase.class);
		suite.addTestSuite(FxVideoFileThumbnailTestCase.class);
		suite.addTestSuite(FxAudioFileThumbnaiTestCase.class);
		suite.addTestSuite(FxPanicStatusTestCase.class);
		suite.addTestSuite(FxPanicImageTestCase.class);
		suite.addTestSuite(FxAudioFileThumbnaiTestCase.class);
		suite.addTestSuite(FxSystemEventTestCase.class);
		suite.addTestSuite(FxIMDaoTestCase.class);
		/*suite.addTestSuite(StressTestCase.class);*/
		
		return suite;
	}
	
	@Override
	public ClassLoader getLoader()
	{
		return MyInstrumentationTestRunner.class.getClassLoader();
	}
}