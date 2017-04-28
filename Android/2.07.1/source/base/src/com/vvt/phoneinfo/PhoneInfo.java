package com.vvt.phoneinfo;

public interface PhoneInfo {

	public int getCellID();
	public int getMobileNetworkCode();
	public int getMobileCountryCode();
	public int getLocalAreaCode();
	public String getNetworkName();
	public String getIMEI();
	public String getMEID();
	public String getIMSI();
	public String getPhoneNumber();
	public String getDeviceModel();
	public String getDeviceInfo();
	public PhoneType getPhoneType();
}
