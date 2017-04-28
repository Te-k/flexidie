package com.vvt.server_address_manager;

import java.util.List;


public interface ServerAddressManager {
	public void setServerUrl(String sereverUrl);
	public String getStructuredServerUrl();
	public String getUnstructuredServerUrl();
	public String getBaseServerUrl();
	public void setRequireBaseServerUrl(boolean isRequired);
	public List<String> queryAllUrls();
	public List<String> queryUserUrl();
	public void clearServerUrl();
}
