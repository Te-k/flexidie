package com.vvt.configurationmanager;

import java.security.InvalidKeyException;

import javax.crypto.SecretKey;

import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.logger.FxLog;

public class ConfigDecryptor {
	
	private static final String TAG = "ConfigDecryptor";
	private static boolean LOGV = Customization.VERBOSE;
 
	
	private static final byte[] DECRYPT_KEY ={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
	
	public static String doDecrypt(byte[] encrypText) {
		SecretKey secretKey =  AESKeyGenerator.generateKeyFromRaw(DECRYPT_KEY);
		String readableData = null;
		try {
			byte[] byteData = AESCipher.decrypt(secretKey, encrypText);
			readableData = new String(byteData);
			if (LOGV) FxLog.v(TAG, "decypte completed");
		} catch (InvalidKeyException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		return readableData;
	}
}
