package com.vvt.phoneinfo;

public class NetworkInfo {
	
	/**
	 * GSM or CDMA
	 */
	private String type = "UNKNOWN";
	
	/**
	 * Network operator name
	 */
	private String operatorName = "UNKNOWN";

	/**
	 * Mobile Country Code
	 */
	private String mcc;
	
	/**
	 * Mobile Network Code
	 */
	private String mnc;
	
	/**
	 * Location Area Code (LAC) for GSM, Network ID (NID) for CDMA
	 */
	private int lac;
	
	/**
	 * Cell ID (CID) for GSM, Base Station ID (BID) for CDMA
	 */
	private int cid;
	
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getOperatorName() {
		return operatorName;
	}
	public void setOperatorName(String operatorName) {
		this.operatorName = operatorName;
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
	public int getLac() {
		return lac;
	}
	public void setLac(int lac) {
		this.lac = lac;
	}
	public int getCid() {
		return cid;
	}
	public void setCid(int cid) {
		this.cid = cid;
	}
	public String getMcc() {
		return mcc;
	}
}
