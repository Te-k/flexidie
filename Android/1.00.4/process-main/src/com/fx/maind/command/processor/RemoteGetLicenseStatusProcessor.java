package com.fx.maind.command.processor;

import com.vvt.daemon.appengine.AppEngine;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;

public class RemoteGetLicenseStatusProcessor {
	
	private AppEngine mAppEngine;
	
	public RemoteGetLicenseStatusProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public LicenseStatus process() {
		LicenseStatus licenseStatus = LicenseStatus.UNKNOWN;
		LicenseManager licenseManager = mAppEngine.getLicenseManager();
		if (licenseManager != null && licenseManager.getLicenseInfo() != null) {
			licenseStatus = licenseManager.getLicenseInfo().getLicenseStatus();
		}
		return licenseStatus;
	}
}
