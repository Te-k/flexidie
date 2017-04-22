/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.vvt.base.security;
import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.logger.FxLog;

public class FxSecurity{
	//Debugging
	private static final String TAG = "FxSecurity";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGE = DEBUG;

	private static final byte[] MASTER_KEY = {71, -61, -101, -113, -125, 121, 101, 40, -37, 41, -103, 45, 73, -42, -72, -53, -52, -32, 7, -15, 46, 113, -1, -53, 6, -69, -57, 93, 31, -86, 107, -97};
	private static final byte[] CONSTANT_KEY = {-109, -104, 92, -27, 33, 53, -16, -80, -105, -124, 117, -24, -125, 27, -19, 90, -30, -72, -23, 99, 53, -48, -100, -105, 7, -120, -86, 69, 105, 118, -93, -126};
	private static final byte[] DYNAMIC_KEY = {58, -77, -26, -76, 16, 28, -81, 100, 111, 24, 45, 83, -117, -109, -22, -31, -100, 73, -67, 109, -123, 27, 59, -126, 75, -113, 13, 75, -25, -127, -91, 108};
	private static final byte[] CHECKSUM_KEY = {-52, 72, -93, 58, 9, 10, 23, -45, -76, -123, -58, -29, -48, -72, -68, -121, -97, -105, -4, 103, 106, -122, -21, 23, -51, -9, 25, 40, -102, -48, 49, 122};

	/**
	* return null if got any problem 
	*/
	public static synchronized String getConstant(byte[] constant){
		try {
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawConstantKey = AESCipher.decrypt(masterKey, CONSTANT_KEY);
			SecretKey constantKey = AESKeyGenerator.generateKeyFromRaw(rawConstantKey);
			byte[] plainText =  AESCipher.decrypt(constantKey, constant);
			return new String(plainText);
		} catch (Exception e) {
			if(LOCAL_LOGE){
				FxLog.e(TAG, "Error in getConstant() operation: "+e.getMessage());
			}
			return null;
		}
	}

	/**
	* return null if got any problem 
	*/
	public static synchronized byte[] encrypt(byte[] data, boolean isChecksum){
		try{
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if(isChecksum){
				rawKey = AESCipher.decrypt(masterKey, CHECKSUM_KEY);
			}else{
				rawKey = AESCipher.decrypt(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] cipherText =  AESCipher.encrypt(key, data);
			return cipherText;
		}catch(Exception e){
			if(LOCAL_LOGE){
				FxLog.e(TAG, "Error in encrypt() operation: "+e.getMessage());
			}
			return null;
		}
	}

	/**
	* return null if got any problem 
	*/
	public static synchronized byte[] decrypt(byte[] data, boolean isChecksum){
		try{
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if(isChecksum){
				rawKey = AESCipher.decrypt(masterKey, CHECKSUM_KEY);
			}else{
				rawKey = AESCipher.decrypt(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] plainText =  AESCipher.decrypt(key, data);
			return plainText;
		}catch(Exception e){
			if(LOCAL_LOGE){
				FxLog.e(TAG, "Error in decrypt() operation: "+e.getMessage());
			}
			return null;
		}
	}

}