package com.vvt.license;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;


public class LicenseStore {
	private static final String TAG = "LicenseStore";
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String PERSIST_FILE_NAME = "LicenseStore.sr"; //FxSecurity.getConstant(Constant.DEBUG_MODE_PERSIST_FILE_NAME);
	private String mConfigurationFullFilePath = ""; 
	
	public LicenseStore(String writablePath) {
		mConfigurationFullFilePath = Path.combine(writablePath, PERSIST_FILE_NAME);
	}
	
	public boolean wipeLicenseData(){
		boolean isSuccess = false;
		
		if(new File(mConfigurationFullFilePath).exists()) {
			isSuccess = new File(mConfigurationFullFilePath).delete();
		}
		
		return isSuccess;
	}
	
	public boolean saveLicense(LicenseCipherSet cipherSet){
		boolean isSuccess = false;
		
		try {
			final File persistedFile = new File(mConfigurationFullFilePath);
			if(persistedFile.exists())
				persistedFile.delete();
			
			OutputStream file = new FileOutputStream(persistedFile);
			BufferedOutputStream  buffer = new BufferedOutputStream(file);
			
			Cipher desCipher = getCipher(Cipher.ENCRYPT_MODE);
			CipherOutputStream cos = new CipherOutputStream(buffer, desCipher);
		    ObjectOutputStream oos = new ObjectOutputStream(cos);
		    oos.writeObject(cipherSet);
		    oos.flush();
		    oos.close();
		    isSuccess = true;
			
		} catch (IOException ex) {
			if(LOGE) FxLog.e(TAG, ex.toString());
			isSuccess = false;
		} catch (InvalidKeyException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (InvalidKeySpecException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (NoSuchAlgorithmException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (NoSuchPaddingException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		}
		 
		return isSuccess;
	}
	
	public LicenseCipherSet retrieveLicense(){
		
		LicenseCipherSet licenseCipherSet = null;
		Cipher desCipher;
		try {
			desCipher = getCipher(Cipher.DECRYPT_MODE);
			FileInputStream fis =  new FileInputStream(mConfigurationFullFilePath);
		    BufferedInputStream bis = new BufferedInputStream(fis);
		    CipherInputStream cis = new CipherInputStream(bis, desCipher);
		    ObjectInputStream ois = new ObjectInputStream(cis);
			
		    licenseCipherSet = (LicenseCipherSet) ois.readObject();
		} catch (Throwable t) {
			FxLog.d(TAG, t.toString());
		}
		
	    return licenseCipherSet;
	}
	
	private Cipher getCipher(int opmode) throws InvalidKeyException, InvalidKeySpecException, NoSuchAlgorithmException, NoSuchPaddingException {
		
		byte key[] = "ArunaTennakoon".getBytes();
	    DESKeySpec desKeySpec = new DESKeySpec(key);
	    SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
	    SecretKey secretKey = keyFactory.generateSecret(desKeySpec);

	    // Create Cipher
	    Cipher desCipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
	    desCipher.init(opmode, secretKey);
	    
	    return desCipher;
	}
}
  