package com.vvt.data_delivery_manager.tests;

import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;

public class MockLicenseManager implements LicenseManager{

	private static String activationCode;
	public static void setActivationCode(String activateode) {
		activationCode = activateode;
	}
	
	@Override
	public void resetLicense() {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public boolean updateLicense(com.vvt.license.LicenseInfo licenseInfo) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public LicenseInfo getLicenseInfo() {
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(activationCode);
		return licenseInfo;
	}

	@Override
	public boolean isActivated(int productId, String hashTail) {
		// TODO Auto-generated method stub
		return false;
	}
	
	

	
}
