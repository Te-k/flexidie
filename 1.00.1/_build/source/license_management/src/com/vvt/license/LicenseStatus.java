package com.vvt.license;

/**
 * @author tanakharn
 * @version 1.0
 * @created 17-Aug-2011 2:23:51 PM
 */
public enum LicenseStatus {
	UNKNOWN(0),
	DEACTIVATED(1),
	ACTIVATED(2),
	EXPIRED(3),
	DISABLED(4);
	
	
	private final int fStatus;
	private LicenseStatus(int status){
		fStatus = status;
	}
	
	public int getStatusValue(){
		return fStatus;
	}
	
	public static LicenseStatus getLicenseStatusByStatusValue(int status){
		
		LicenseStatus license;
		switch(status){
			case 0:	license = UNKNOWN;break;
			case 1:	license = DEACTIVATED;break;
			case 2: license = ACTIVATED;break;
			case 3: license = EXPIRED;break;
			case 4: license = DISABLED;break;
			default: license = UNKNOWN;			
		}
	
		return license;
	}
}