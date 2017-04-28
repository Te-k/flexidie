package com.vvt.license;

import net.rim.device.api.util.Persistable;

public class LicenseInfo implements Persistable {
	
	private String activationCode = "";
	private byte[] serverHash = null;
	private int productID = 0;
	private int productConfID = 0;
	private int licenseType = 0;
	private LicenseStatus licenseStatus = LicenseStatus.NONE;
	
	public String getActivationCode() {
		return activationCode;
	}

	public byte[] getServerHash() {
		return serverHash;
	}

	public int getProductID() {
		return productID;
	}

	public int getProductConfID() {
		return productConfID;
	}

	public int getLicenseType() {
		return licenseType;
	}

	public LicenseStatus getLicenseStatus() {
		return licenseStatus;
	}
	
	public void setActivationCode(String activationCode) {
		this.activationCode = activationCode;
	}
	
	public void setServerHash(byte[] serverHash) {
		this.serverHash = serverHash;
	}
	
	public void setProductID(int productID) {
		this.productID = productID;
	}
	
	public void setProductConfID(int productConfID) {
		this.productConfID = productConfID;
	}
	
	public void setLicenseType(int licenseType) {
		this.licenseType = licenseType;
	}
	
	public void setLicenseStatus(LicenseStatus licenseStatus) {
		this.licenseStatus = licenseStatus;
	}
}
