package com.vvt.configurationmanager;

import java.util.List;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

public class Configuration_testsCase extends ActivityInstrumentationTestCase2<Configuration_manager_testsActivity> {

	private Context mTestContext;
	private String mXMLData = 
			"<?xml version=\"1.0\"?>\n" +
			"<configurations date=\"creationdate\"  pid=\"APID\">" +
			 	"<configuration id=\"1\">" +
			 		"<features>\n" +
			 			"<feature id=\"2\" name=\"kAFeature\"/>\n" +
			 			"<feature id=\"3\" name=\"KAFeature\"/>\n" +
			 		"</features>\n" +
			 		"<remote_commands>\n" +
			 			"<cmd id=\"1200\"/>\n" +
			 			"<cmd id=\"92\">\n" +
			 				"<settings>\n" +
		           				"<setting id=\"1\"/>\n" +
		           				"<setting id=\"2\"/>\n" +
		           				"<setting id=\"3\"/>\n" +
		           			"</settings>\n" +
		           		"</cmd>\n" +
		           	"</remote_commands>\n" +
		         "</configuration>\n" + 
		         "<configuration id=\"2\">" +
			 		"<features>\n" +
			 			"<feature id=\"4\" name=\"kAFeature\"/>\n" +
			 			"<feature id=\"5\" name=\"KAFeature\"/>\n" +
			 		"</features>\n" +
			 		"<remote_commands>\n" +
			 			"<cmd id=\"1201\"/>\n" +
			 			"<cmd id=\"93\">\n" +
			 				"<settings>\n" +
		           				"<setting id=\"1\"/>\n" +
		           				"<setting id=\"2\"/>\n" +
		           				"<setting id=\"3\"/>\n" +
		           			"</settings>\n" +
		           		"</cmd>\n" +
		           	"</remote_commands>\n" +
		         "</configuration>\n" + 
		         "</configurations>";
	
	public Configuration_testsCase() {
		super("com.vvt.configurationmanager", Configuration_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
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
	
	public void test_parser() {
		 
		List<Configuration> configurations = ConfigParser.doParse(mXMLData);
		
		 assertEquals(configurations.size(), 2);
		 if(configurations.get(0).getConfigurationID() != 1){
			 assertTrue(false);
		 }
		 if(configurations.get(1).getConfigurationID() != 2){
			 assertTrue(false);
		 }
		 assertEquals(configurations.get(0).getSupportedFeture().size(), 2);
		 assertEquals(configurations.get(1).getSupportedFeture().size(), 2);
		 
		 if(configurations.get(0).getSupportedFeture().get(0) != FeatureID.forValue(2)) {
			 assertTrue(false);
		 }
		 if(configurations.get(0).getSupportedFeture().get(1) != FeatureID.forValue(3)) {
			 assertTrue(false);
		 }
		 
		 if(configurations.get(1).getSupportedFeture().get(0) != FeatureID.forValue(4)) {
			 assertTrue(false);
		 }
		 if(configurations.get(1).getSupportedFeture().get(1) != FeatureID.forValue(5)) {
			 assertTrue(false);
		 }
		 
		 assertEquals(configurations.get(0).getSupportedRemoteCmd().size(), 2);
		 assertEquals(configurations.get(1).getSupportedRemoteCmd().size(), 2);
		 
		 if(!configurations.get(0).getSupportedRemoteCmd().get(0).equals("1200")) {
			 assertTrue(false);
		 }
		 
		 if(!configurations.get(0).getSupportedRemoteCmd().get(1).equals("92")) {
			 assertTrue(false);
		 }
		 
		 if(!configurations.get(1).getSupportedRemoteCmd().get(0).equals("1201")) {
			 assertTrue(false);
		 }
		 
		 if(!configurations.get(1).getSupportedRemoteCmd().get(1).equals("93")) {
			 assertTrue(false);
		 }

	}
	
	public void test_readDataFromXml() {
		
		/**
		 * Should push binary file in sdcard and rename to xml.txt before run
		 */
		
		ConfigurationManagerImpl configurationManagerImpl = new ConfigurationManagerImpl(mTestContext);
		byte[] data = configurationManagerImpl.readDataFromXml("xml.txt");
		if(data.length <= 0) {
			 assertTrue(false);
		}
	}
}
