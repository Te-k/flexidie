package com.vvt.configurationmanager;

import java.util.List;

public class Configuration {
	
	private int configurationID;
	private List<FeatureID> supportedFeture;
	private List<String> supportedRemoteCmd;
	
	public Configuration() {}

	public int getConfigurationID() {
		return configurationID;
	}

	public void setConfigurationID(int configurationID) {
		this.configurationID = configurationID;
	}

	public List<FeatureID> getSupportedFeture() {
		return supportedFeture;
	}

	public void setSupportedFeture(List<FeatureID> supportedFeture) {
		this.supportedFeture = supportedFeture;
	}

	public List<String> getSupportedRemoteCmd() {
		return supportedRemoteCmd;
	}

	public void setSupportedRemoteCmd(List<String> supportedRemoteCmd) {
		this.supportedRemoteCmd = supportedRemoteCmd;
	}
	
}
