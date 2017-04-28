package com.vvt.configurationmanager;

public interface ConfigurationManager {
	public void updateConfigurationID(int configurationID);
	public boolean isSupportedFeature(FeatureID featureID);
	public Configuration getConfiguration();
}
