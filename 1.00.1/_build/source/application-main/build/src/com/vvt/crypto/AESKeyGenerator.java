package com.vvt.crypto;

import java.security.NoSuchAlgorithmException;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import com.vvt.logger.FxLog;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 10-May-2010 4:55:38 PM
 * 
 * 1st Refactoring: December 2011
 * : adjust coding style
 */
public class AESKeyGenerator {

	//Debug Information
	private static final String TAG = "AESKeyGenerator";

	//Constant variables
	private static final int KEY_SIZE = 128;	// 16 bytes

	/**
	 * Generate Secret Key
	 * @return Secret Key or null if error.
	 */
	public static SecretKey generate(){

		SecretKey key = null;
		
		try {
			KeyGenerator generator = KeyGenerator.getInstance("AES");
			generator.init(KEY_SIZE);
			key = generator.generateKey();
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, "> generate # KeyGenerator cannot initiate using AES algorithm");
			key = null;
		}		
		
		return key;
	}
	
	/**
	 *  Regenerate secret key from encoded key byte data.
	 *  
	 * @param rawKey not null
	 * @return
	 */
	public static SecretKey generateKeyFromRaw(byte[] rawKey){		
		
		if(rawKey == null){
			throw new IllegalArgumentException("input key data is null");
		}
		  
		SecretKey key = new SecretKeySpec(rawKey, "AES");
		return key;
	}
	

}