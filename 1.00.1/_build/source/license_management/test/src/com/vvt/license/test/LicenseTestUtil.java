package com.vvt.license.test;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.content.Context;
import android.telephony.TelephonyManager;

import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;

/**
 * @author tanakharn
 *
 * Utility class provides facilities for every test cases.
 */
public class LicenseTestUtil {
	
	/*
	 * Constants
	 */
	protected static final int PRODUCT_ID = 4202;
	protected static final int CONFIGURATION_ID = 104;
	protected static final String ACTIVATION_CODE = "1150";
	protected static final String HASH_TAIL = "1FD0EDB9EA";
		
	
	private static byte[] calculateMd5(Context context){
		//calculate MD5
		 StringBuffer buff = new StringBuffer();
		 buff.append(PRODUCT_ID);
		 buff.append(CONFIGURATION_ID);
		 buff.append(getDeviceId(context));
		 buff.append(HASH_TAIL);

		 byte[] md5 = null;
		 String data = buff.toString();
		 try {
			MessageDigest digester = MessageDigest.getInstance("MD5");
			byte[] bytes = data.getBytes();
			digester.update(bytes, 0, bytes.length);
			md5 = digester.digest();
		} catch (NoSuchAlgorithmException e) {
			md5 = null;
		} catch (NullPointerException e){
			md5 = null;
		}

		 return md5;
	}
	private static String getDeviceId(Context context){
		
		 TelephonyManager teleMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
	    	/*
	    	 *  require permission android.permission.READ_PHONE_STATE
	    	 */
		 String deviceId = teleMan.getDeviceId();
	 
		 return deviceId;
		}
	
	public static LicenseInfo generateUnknownLicense(Context context){
			
		LicenseInfo license = new LicenseInfo();
		license.setConfigurationId(CONFIGURATION_ID);
		license.setMd5(calculateMd5(context));
		license.setActivationCode(ACTIVATION_CODE);
		LicenseStatus licenseStatus = LicenseStatus.UNKNOWN;
		license.setLicenseStatus(licenseStatus);
		 
		return license;
	 }
	 
	 public static LicenseInfo generateDeactivatedLicense(Context context){
			
		LicenseInfo license = new LicenseInfo();
		license.setConfigurationId(CONFIGURATION_ID);
		license.setMd5(calculateMd5(context));
		license.setActivationCode(ACTIVATION_CODE);
		LicenseStatus licenseStatus = LicenseStatus.DEACTIVATED;
		license.setLicenseStatus(licenseStatus);
		
		return license;
	 }
	 	 
	 public static LicenseInfo generateActivatedLicense(Context context){
		
		LicenseInfo license = new LicenseInfo();
		license.setConfigurationId(CONFIGURATION_ID);
		license.setMd5(calculateMd5(context));
		license.setActivationCode(ACTIVATION_CODE);
		LicenseStatus licenseStatus = LicenseStatus.ACTIVATED;
		license.setLicenseStatus(licenseStatus);
		 
		return license;
	 }
	 
	 public static LicenseInfo generateExpiredLicense(Context context){
			
		LicenseInfo license = new LicenseInfo();
		license.setConfigurationId(CONFIGURATION_ID);
		license.setMd5(calculateMd5(context));
		license.setActivationCode(ACTIVATION_CODE);
		LicenseStatus licenseStatus = LicenseStatus.EXPIRED;
		license.setLicenseStatus(licenseStatus);
		 
		return license;
	 }
	 
	 public static LicenseInfo generateDisabledLicense(Context context){
			
			LicenseInfo license = new LicenseInfo();
			license.setConfigurationId(CONFIGURATION_ID);
			license.setMd5(calculateMd5(context));
			license.setActivationCode(ACTIVATION_CODE);
			LicenseStatus licenseStatus = LicenseStatus.DISABLED;
			license.setLicenseStatus(licenseStatus);
			 
			return license;
		 }
}
