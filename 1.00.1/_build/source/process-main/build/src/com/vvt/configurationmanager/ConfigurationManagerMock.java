package com.vvt.configurationmanager;

import java.util.ArrayList;
import java.util.List;

public class ConfigurationManagerMock  implements ConfigurationManager{
	private int mCurrentConfID;
	private Configuration mConfiguration;
	
	public ConfigurationManagerMock() {
		mCurrentConfID = 0;
		mConfiguration = new Configuration();
		
		List<FeatureID> featureIDs = new ArrayList<FeatureID>();
		featureIDs.add(FeatureID.FEATURE_ID_EVNET_CALL);
//		featureIDs.add(FeatureID.FEATURE_ID_EVNET_CONTACT);
		featureIDs.add(FeatureID.FEATURE_ID_EVNET_LOCATION);
		featureIDs.add(FeatureID.FEATURE_ID_EVNET_MMS);
		featureIDs.add(FeatureID.FEATURE_ID_EVNET_SMS);
		featureIDs.add(FeatureID.FEATURE_ID_EVNET_EMAIL);
		
		List<String> rmtCommands = new ArrayList<String>();
		rmtCommands.add("2");
		rmtCommands.add("64");
		rmtCommands.add("92");
		rmtCommands.add("60");
		rmtCommands.add("14140");
		rmtCommands.add("14141");
		rmtCommands.add("14142");
		rmtCommands.add("300");
		rmtCommands.add("200");
		rmtCommands.add("306");
		rmtCommands.add("52");
		rmtCommands.add("53");
		rmtCommands.add("101");
		rmtCommands.add("396");
		rmtCommands.add("397");
		rmtCommands.add("398");
		rmtCommands.add("399");
		rmtCommands.add("67");
		rmtCommands.add("62");
		rmtCommands.add("5");
		rmtCommands.add("147");
		rmtCommands.add("14852");
		rmtCommands.add("14143");
		rmtCommands.add("65");
		
		mConfiguration.setConfigurationID(mCurrentConfID);
		mConfiguration.setSupportedFeture(featureIDs);
		mConfiguration.setSupportedRemoteCmd(rmtCommands);
	}

	@Override
	public void updateConfigurationID(int configurationID) {
		mCurrentConfID = configurationID;
		mConfiguration.setConfigurationID(configurationID);
	}

	@Override
	public boolean isSupportedFeature(FeatureID featureID) {
		return mConfiguration.getSupportedFeture().contains(featureID);
	}

	@Override
	public Configuration getConfiguration() {
		return mConfiguration;
	}
}
