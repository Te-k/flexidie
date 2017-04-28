package com.vvt.license.test;

import junit.framework.Assert;
import android.os.ConditionVariable;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.license.LicenseChangeListener;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseManagerImpl;
import com.vvt.license.LicenseStatus;

/**
 * @author tanakharn
 * Test commit new license and observe for license changed call back.
 */
public class LicenseManagerCallbackTest extends AndroidTestCase implements LicenseChangeListener {
	
		
	 private boolean mCallbackOccurs;
	 private ConditionVariable mCondition;
	 
	 public void testResetLicense(){
		 String writePath  = getContext().getCacheDir().getAbsolutePath();
		 
		 final LicenseManagerImpl licenseMan = new LicenseManagerImpl(getContext(), writePath);
		 licenseMan.resetLicense();
	 }
	 
	 public void testUpdateLicense(){
	
		 String writePath  = getContext().getCacheDir().getAbsolutePath();
		 
		 final LicenseManagerImpl licenseMan = new LicenseManagerImpl(getContext(), writePath);
		 licenseMan.resetLicense();
		 
		 LicenseInfo licenseInfo = new LicenseInfo();
		 licenseInfo.setActivationCode("10246");
		 licenseInfo.setConfigurationId(200);
		 licenseInfo.setLicenseStatus(LicenseStatus.ACTIVATED);
		 licenseInfo.setMd5(null);
		 licenseMan.updateLicense(licenseInfo);
		 
		 assertEquals(licenseMan.getActivationCode(), "10246");
			 	 		 
		 assertEquals(licenseMan.getConfigurationId(), 200);
		 
		 assertEquals(licenseMan.getMd5(), null);
	 }
	 
	 public void testGetLicenseInfo(){
		 String writePath  = getContext().getCacheDir().getAbsolutePath();
		 
		 final LicenseManagerImpl licenseMan = new LicenseManagerImpl(getContext(), writePath);
		 licenseMan.resetLicense();
		
		 LicenseInfo licenseInfo = new LicenseInfo();
		 licenseInfo.setActivationCode("10246");
		 licenseInfo.setConfigurationId(200);
		 licenseInfo.setLicenseStatus(LicenseStatus.ACTIVATED);
		 licenseInfo.setMd5(null);
		 licenseMan.updateLicense(licenseInfo);
		 
		 if(licenseMan.getLicenseInfo() == null) {
			 Assert.fail("getLicenseInfo can not be null");
		 }
	 }
	 
	 public void testDoubleUpdateLicense() {
		 String writePath  = getContext().getCacheDir().getAbsolutePath();
		 
		 final LicenseManagerImpl licenseMan = new LicenseManagerImpl(getContext(), writePath);
		 licenseMan.resetLicense();
		 

		 LicenseInfo licenseInfo = new LicenseInfo();
		 licenseInfo.setActivationCode("10246");
		 licenseInfo.setConfigurationId(200);
		 licenseInfo.setLicenseStatus(LicenseStatus.ACTIVATED);
		 licenseInfo.setMd5(null);
		 licenseMan.updateLicense(licenseInfo);
		 
		 licenseInfo.setActivationCode("10247");
		 licenseMan.updateLicense(licenseInfo);
		 
		 assertEquals(licenseMan.getActivationCode(), "10247");
		 
	 }
	 
	public void testCallBackResetLicense() {
		mCallbackOccurs = false;
		mCondition = new ConditionVariable();

		String writePath = getContext().getCacheDir().getAbsolutePath();

		final LicenseManagerImpl licenseMan = new LicenseManagerImpl(getContext(), writePath);
		licenseMan.setLicenseChangeListener(this);
		licenseMan.resetLicense();
		
		// wait for call back
		mCondition.block(5000);

		assertEquals(true, mCallbackOccurs);
	}

	@Override
	public void onLicenseChanged(LicenseInfo license) {
		mCallbackOccurs = true;
		mCondition.open();
		
	}

}
