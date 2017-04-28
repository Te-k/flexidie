package com.vvt.license;

public interface LicenseManager {
	public LicenseInfo getLicenseInfo();
	public void resetLicense();
	public boolean updateLicense(LicenseInfo licenseInfo);
	public boolean isActivated(int productId, String hashTail);
}
