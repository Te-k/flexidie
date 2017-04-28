package com.vvt.license;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.content.Context;
import android.telephony.TelephonyManager;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.logger.FxLog;

/**
 * @author tanakharn
 * @version 1.0
 * @created 17-Aug-2011 2:23:45 PM
 */
public class LicenseManagerImpl implements LicenseManager{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "LicenseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	/*
	 * Members
	 */
	private LicenseInfo mLicenseInfo;
	private LicenseChangeListener mListeners;
	private Context mContext;
	private LicenseStore mLicenseStore;
	
	
	/**
	 * Private constructor. 
	 */
	public LicenseManagerImpl(Context context, String writablePath) {
		if(LOGV) FxLog.v(TAG, "Initilizing ...");
		/*
		 * load persisted license info from database
		 */
		if(LOGV) FxLog.v(TAG, "> Constructing # Retrieving license data from database to memory.");
		mLicenseInfo = new LicenseInfo();
		mLicenseStore = new LicenseStore(writablePath);
		mContext = context;

		retrieveFromdatabase();
	}
	
	private void retrieveFromdatabase() {

		LicenseCipherSet cipherSet = mLicenseStore.retrieveLicense();
		
		if(cipherSet != null){
			byte[] atvCodePlainText = FxSecurity.decrypt(cipherSet.activationCodeCipher, false);
			byte[] configIdPlainText = FxSecurity.decrypt(cipherSet.configIdCipher, false);
			byte[] licenseStatusPlainText = FxSecurity.decrypt(cipherSet.licenseStatusCipher, false);
			byte[] md5PlainText = FxSecurity.decrypt(cipherSet.md5Cipher, false);
				
			if( (atvCodePlainText != null)
					&& (configIdPlainText != null)
					&& (licenseStatusPlainText != null)
					&& (md5PlainText != null)){
				
				//decrypt all fields success
				
				mLicenseInfo.setActivationCode(new String(atvCodePlainText));

				String gg = new String(configIdPlainText);
				
				mLicenseInfo.setConfigurationId(Integer.parseInt(gg));
				mLicenseInfo.setLicenseStatus(LicenseStatus.getLicenseStatusByStatusValue(licenseStatusPlainText[0]));
				mLicenseInfo.setMd5(md5PlainText);
				
				if(LOGV) FxLog.v(TAG, "> Constructing # Retriving license data done.");
			}else{
				/*
				 * Cannot decrypt data, keep mLicenseInfo as default (invalid) value
				 */
				//FxLogging
				if(atvCodePlainText == null){
					FxLog.w(TAG, "> Constructing # Cannot decrypt activation code");
				}
				if(configIdPlainText == null){
					FxLog.w(TAG, "> Constructing # Cannot decrypt configuration ID");
				}
				if(licenseStatusPlainText == null){
					FxLog.w(TAG, "> Constructing # Cannot decrypt license status");
				}
				if(md5PlainText == null){
					FxLog.w(TAG, "> Constructing # Cannot decrypt MD5");
				}
			}

		}else{
			if(LOGE) FxLog.e(TAG, "> Constructing # Cannot retrieve license data or no data in license storage.");
			/*
			 * Do nothing, in this case hold default license info.
			 */
		}			
	}
	
	private boolean commitLicense(LicenseInfo license)  {
		
		boolean commitResult = false;
 				
		// Above was changed because Activation componenet
		if (((license != null) && (mContext != null))
				&& (license.getActivationCode() != null)) {

			// all input are valid, check equality of holding license and given
			// license
			// if( (mLicenseInfo != null) && (mLicenseInfo.equals(license)) ){
			if ((mLicenseInfo == null) || (!mLicenseInfo.equals(license))) {
				// the old license is null or the given license doesn't equal
				// with the old one.
				// encrypt data
				byte[] tempByteArray = new byte[1];
				tempByteArray[0] = Integer
						.valueOf(license.getConfigurationId()).byteValue();

				byte[] configIdCipher = FxSecurity
						.encrypt(String.valueOf(license.getConfigurationId())
								.getBytes(), false);
				byte[] atvCodeCipher = FxSecurity.encrypt(license
						.getActivationCode().getBytes(), false);
				byte[] md5Cipher = FxSecurity.encrypt(license.getMd5(), false);
				tempByteArray[0] = Integer.valueOf(
						license.getLicenseStatus().getStatusValue())
						.byteValue();
				byte[] licenseStatusCipher = FxSecurity.encrypt(tempByteArray,
						false);

				// ) open license database
				// open database success

				// wipe old license data in database
				// we don't care wipe out result.
				mLicenseStore.wipeLicenseData();

				// save new license data
				LicenseCipherSet cipherSet = new LicenseCipherSet();
				cipherSet.activationCodeCipher = atvCodeCipher;
				cipherSet.configIdCipher = configIdCipher;
				cipherSet.licenseStatusCipher = licenseStatusCipher;
				cipherSet.md5Cipher = md5Cipher;
				boolean isSuccess = mLicenseStore.saveLicense(cipherSet);
				if (isSuccess) {
					// save license success

					// update current holden license to new one
					mLicenseInfo = license;

					// notify listener for license changed
					if (mListeners != null) {
						mListeners.onLicenseChanged(license);
					}

					commitResult = true;
					if(LOGV) FxLog.v(TAG,
							"> commitLicense # Commit "
									+ mLicenseInfo.getLicenseStatus()
									+ " license OK");
				} else {
					// cannot save license
					commitResult = false;
					if(LOGE) FxLog.e(TAG,
							"> commitLicense # Cannot save license to database");
				}

			} else {
				// cannot open database
				commitResult = false;
				if(LOGE) FxLog.e(TAG, "> commitLicense # Cannot open license database");
			}
		} else {
			// the given license is equals with the old one, stop
			commitResult = false;
			if(LOGD) FxLog.d(TAG, "> commitLicense # the given license is equal with the old one");
		}
		
		return commitResult;
	}

	public boolean isActivated(int productId, String hashTail){
		/*
		 * A line of code below is vulnerable to hack if user copy license database from activated device
		 * to non activated device, in run time application in non activated device
		 * will recognize that the device already activated.
		 * So, ignore it.
		 */
		//return (mLicenseInfo.getLicenseStatus() == LicenseStatus.ACTIVATED);
		
		//For testing only
		/*mLicenseInfo.setMd5(null);
		mLicenseInfo.setMd5(new byte[0]);
		mLicenseInfo.setConfigurationId(-1);*/
		
		boolean result = false;
		if(mLicenseInfo != null){
			if(mLicenseInfo.getLicenseStatus() == LicenseStatus.ACTIVATED){
				byte[] holdingMd5 = mLicenseInfo.getMd5();
				if( (holdingMd5 != null) && (holdingMd5.length != 0) ){
					int configId = mLicenseInfo.getConfigurationId();
					if(configId != -1){
						if(LOGV) FxLog.v(TAG, "> isActivated # Calculating and compare checksum value");
						StringBuffer buff = new StringBuffer();
						buff.append(productId);
						buff.append(configId);
						buff.append(getDeviceId(mContext));
						buff.append(hashTail);
						byte[] runtimeMd5 = calculateMd5(buff.toString());
						result = MessageDigest.isEqual(runtimeMd5, holdingMd5);
					}else{
						/*
						 * If configuration ID = -1, it means we can't retrieve license data from license storage
						 * or there is no data in license storage.
						 */
						result = false;
						if(LOGD) FxLog.d(TAG, "> isActivated # Current holing configuration ID is -1");
					}
				}else{
					/*
					 * If mLicenseInfo is not NULL then MD5 value should at least present as zero length byte[] 
					 */
					result = false;
					if(LOGD) FxLog.d(TAG, "> isActivated # Current holding MD5 doesn't exist ! ");
				}	
			}else{
				result = false;
				if(LOGD) FxLog.d(TAG, "> isActivated # Current holding status is not Activated!");
			}		
		}else{
			/*
			 * mLicenseInfo is NULL, Basically this case never happen. Something goes wrong.
			 */
			result = false;
			if(LOGD) FxLog.d(TAG, "> isActivated # Current holiding license object is NULL. " +
					"Something wrong in initialize time.");
		}
		
		if(LOGV) FxLog.v(TAG, "> isActivated # return "+result);
		return result;
	}
	
	private static String getDeviceId(Context context){
		
		TelephonyManager teleMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    	/*
    	 *  require permission android.permission.READ_PHONE_STATE
    	 */
    	String deviceId = teleMan.getDeviceId(); //this line may return NULL
 
    	return deviceId;
	}
	/**
	 * @param data
	 * @return MD5 value of data or null if error.
	 */
	private static byte[] calculateMd5(String data){
		byte[] md5 = null;
		try {
			MessageDigest digester = MessageDigest.getInstance("MD5");
			byte[] bytes = data.getBytes();
			digester.update(bytes, 0, bytes.length);
			md5 = digester.digest();
		} catch (NoSuchAlgorithmException e) {
			md5 = null;
			if(LOGE) FxLog.e(TAG, "> calculateMd5 # NoSuchAlgorithmException: "+e.getMessage());
		} catch (NullPointerException e){
			md5 = null;
			if(LOGE) FxLog.e(TAG, "> calculateMd5 # NullPointerException: "+e.getMessage());
		}

		 return md5;
	}

	/**
	 * Get current holding Activation code.
	 * @return current holding Activation code or NULL if error.
	 */
	public String getActivationCode() {
		if (mLicenseInfo != null) {
			return mLicenseInfo.getActivationCode();
		} else {
			return null;
		}
	}

	/**
	 * Get current holding Configuration ID.
	 * @return current holding Configuration ID or -1 if error.
	 */
	public int getConfigurationId() {
		if (mLicenseInfo != null) {
			return mLicenseInfo.getConfigurationId();
		} else {
			return -1;
		}
	}
	
	/**
	 * Get current holding License Status.
	 * @return current holding license status
	 */
	public LicenseStatus getLicenseStatus() {
		if (mLicenseInfo != null) {
			return mLicenseInfo.getLicenseStatus();
		} else {
			return LicenseStatus.UNKNOWN;
		}
	}
	
	/**
	 * Get current holding MD5.
	 * @return current holding MD5 or byte[0] if not exist.
	 */
	public byte[] getMd5() {
		if (mLicenseInfo != null) {
			return mLicenseInfo.getMd5();
		} else {
			return new byte[0];
		}
	}
	
	/*
	 * NOTE:
	 * Change this class to support multiple LicenseChangeListener.
	 */
	
	/**
	 * Set LicenseChangeListener to observe license changed.
	 * @param listener or NULL to clear previous listener.
	 */
	public void setLicenseChangeListener(LicenseChangeListener listener){
		mListeners = listener;
	}

	@Override
	public LicenseInfo getLicenseInfo() {
		return mLicenseInfo;
	}


	@Override
	public void resetLicense() { 
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode(FxSecurity.getConstant(Constant.DEFAULT_ACTIVATION_CODE));
		licenseInfo.setConfigurationId(Integer.parseInt(FxSecurity.getConstant(Constant.DEFAULT_CONFIGURATION_ID)));
		licenseInfo.setLicenseStatus(LicenseStatus.DEACTIVATED);
		updateLicense(licenseInfo);
	}


	/**
	 * @param context
	 * @param license
	 * @return TRUE if complete, FALSE if cannot save license to database or 
	 * the given license is equal with the old one.
	 */
	@Override
	public boolean updateLicense(LicenseInfo licenseInfo) {
		return commitLicense(licenseInfo);
	}
	
	// ===================================== Testing purpose methods ========================== //
	/*
	 * The following methods is use only for testing purpose. Comment or remove it after
	 * unit test success.
	 */	

	/**
	 * Use for test only, remove after test phase
	 */
	/*public LicenseInfo getLicenseInfo(){
		return mLicenseInfo;
	}*/
	
	/**
	 * Use for test only, remove after test phase
	 */
	/*public void killInstance(){
		sInstance = null;
	}*/
}