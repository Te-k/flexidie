package com.vvt.license;

import java.util.Arrays;

/**
 * @author tanakharn
 * @version 1.0
 * @created 17-Aug-2011 2:24:36 PM
 */
public class LicenseInfo{

	private int mConfigurationId;
	private byte[] mMd5;
	private String mActivationCode;
	private LicenseStatus mLicenseStatus;
	
	
	/**
	 * Construct LicenseInfo instance with default (Invalid) attributes.
	 */
	public LicenseInfo(){
		mConfigurationId = -1;
		mMd5 = new byte[0];
		mActivationCode = "";
		mLicenseStatus = LicenseStatus.UNKNOWN;
	}

	public int getConfigurationId(){
		return mConfigurationId;
	}

	/**
	 * 
	 * @param configurationId
	 */
	public void setConfigurationId(int configurationId){
		mConfigurationId = configurationId;
	}

	public byte[] getMd5(){
		return mMd5;
	}

	/**
	 * 
	 * @param md5
	 */
	public void setMd5(byte[] md5){
		mMd5 = md5;
	}

	public String getActivationCode(){
		return mActivationCode;
	}

	/**
	 * 
	 * @param activationCode
	 */
	public void setActivationCode(String activationCode){
		mActivationCode = activationCode;
	}

	public LicenseStatus getLicenseStatus(){
		return mLicenseStatus;
	}

	/**
	 * 
	 * @param status
	 */
	public void setLicenseStatus(LicenseStatus status){
		mLicenseStatus = status;
	}
	
	@Override
	public boolean equals(Object o){
		// Return true if the objects are identical.
	    // (This is just an optimization, not required for correctness.)
	    if (this == o) {
	      return true;
	    }
	    
	    // Return false if the other object has the wrong type.
	    // This type may be an interface depending on the interface's specification.
	    if (!(o instanceof LicenseInfo)) {
	      return false;
	    }
	    
	    // Cast to the appropriate type.
	    // This will succeed because of the instanceof, and lets us access private fields.
	    LicenseInfo subject = (LicenseInfo) o;
	    
	    
	    // Check each field. Primitive fields, reference fields, and nullable reference
	    // fields are all treated differently.
	    return ( (mConfigurationId == subject.getConfigurationId())
	    		
	    		&& (mActivationCode == null ? subject.getActivationCode() == null 
	    									: mActivationCode.equals(subject.getActivationCode()))
	    		
	    		&& (mLicenseStatus == subject.getLicenseStatus())
	    		
	    		&& (Arrays.equals(mMd5, subject.getMd5()))
	    		
	    		);
	}

}