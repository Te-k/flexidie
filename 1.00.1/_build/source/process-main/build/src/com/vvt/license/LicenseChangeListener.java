package com.vvt.license;

/**
 * @author tanakharn
 * @version 1.0
 * @created 17-Aug-2011 2:23:59 PM
 */
public interface LicenseChangeListener {

	/**
	 * 
	 * @param license
	 */
	public void onLicenseChanged(LicenseInfo license);

}