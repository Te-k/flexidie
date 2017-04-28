/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.vvt.base.security;
import javax.crypto.SecretKey;

import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.ioutil.Customization;
import java.nio.ByteBuffer;
import android.util.Log;

public class FxSecurity{
	//Debugging
	private static final String TAG = "FxSecurity";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;

	private static final byte[] MASTER_KEY = {-41, -12, -108, -101, 20, 118, 62, 74, -7, -54, -101, 123, 34, 119, -78, 118, 54, 113, -43, -92, -57, 16, -89, -86, -23, -37, 18, 99, -96, 110, 60, 111};
	private static final byte[] CONSTANT_KEY = {84, -4, 42, -78, 108, 118, -70, 21, 8, 19, -113, 87, -57, -14, 108, -101, 38, -71, -117, -65, -93, 6, -40, 106, 41, 41, -128, 11, 57, 88, 83, -98};
	private static final byte[] DYNAMIC_KEY = {126, -3, -52, -13, 72, 18, 118, -64, 10, 65, 60, -96, -82, 87, 86, -17, 78, -50, -27, -35, 89, -83, -128, 63, -29, 127, 115, 88, 11, 52, 48, -78};
	private static final byte[] CHECKSUM_KEY = {-77, -92, -56, 93, 121, 112, -102, 106, 26, 80, 126, 57, -51, 26, 61, 12, -13, -56, -114, -118, 70, 97, 64, -78, 38, 74, -57, -105, -71, -9, 115, 37};

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
				Log.e(TAG, "Error in getConstant() operation: "+e.getMessage());
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
				Log.e(TAG, "Error in encrypt() operation: "+e.getMessage());
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
				Log.e(TAG, "Error in decrypt() operation: "+e.getMessage());
			}
			return null;
		}
	}

}
