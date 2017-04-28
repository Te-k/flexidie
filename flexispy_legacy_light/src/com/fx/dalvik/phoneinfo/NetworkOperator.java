package com.fx.dalvik.phoneinfo;

public class NetworkOperator {

	/**
	 * Mobile Country Code
	 */
	private String mcc;
	
	/**
	 * Mobile Network Code
	 */
	private String mnc;
	
	private String networkOperatorName;
	
	public String getMcc() {
		return mcc;
	}
	public void setMcc(String mcc) {
		this.mcc = mcc;
	}
	public String getMnc() {
		return mnc;
	}
	public void setMnc(String mnc) {
		this.mnc = mnc;
	}
	public String getNetworkOperatorName() {
		return networkOperatorName;
	}
	
	public void setNetworkOperatorName(String aNetworkOperatorName) {
		networkOperatorName = aNetworkOperatorName;
	}
}
