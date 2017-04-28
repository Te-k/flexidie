package com.temp.util.crypto;

import java.security.NoSuchAlgorithmException;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 10-May-2010 4:55:38 PM
 */
public class AESKeyGenerator {

	//Debug Information
	private static final String TAG = "AESKeyGenerator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Constant variables
	private static final int KEY_SIZE = 128;	// 16 bytes
	
	public static SecretKey generate(){
		KeyGenerator generator = null;
		try {
			generator = KeyGenerator.getInstance("AES");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "KeyGenerator can't initiate with AES algorithm");}
		}
		generator.init(KEY_SIZE);
		
		return generator.generateKey();
	}
	
	public static SecretKey generateKeyFromRaw(byte[] rawKey){		
		SecretKey key = new SecretKeySpec(rawKey, "AES");
		return key;
	}
	
}