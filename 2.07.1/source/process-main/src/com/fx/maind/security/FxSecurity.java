/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.fx.maind.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity{

	private static final byte[] MASTER_KEY = {-82, 111, 62, 105, -12, 44, -2, 88, -85, 52, 9, -24, -121, 61, 86, -40, -67, -9, -48, -33, 58, -59, 83, 15, 81, 39, -93, 9, -91, -92, -85, -27};
	private static final byte[] CONSTANT_KEY = {-91, -30, 2, 22, -20, 117, -115, -51, -8, -53, 27, -71, 89, 51, -93, -70, -21, 5, -1, 18, 84, 78, -51, 116, 35, -119, 109, 62, -20, 19, -21, 24};
	private static final byte[] DYNAMIC_KEY = {93, 60, 44, -29, 6, 30, -39, 87, 91, -84, -19, 94, -28, 110, -116, 93, -84, 49, 76, -26, -25, -104, -98, 11, -119, -67, -96, 120, -126, -119, 104, 36};
	private static final byte[] CHECKSUM_KEY = {-25, -88, -49, 117, 117, -104, -91, -90, 113, 60, -29, 46, 54, -9, 124, -92, -30, -81, -113, 86, 8, -81, -39, -12, 15, 45, 94, 36, 23, 28, -66, -124};

	/**
	* return null if got any problem 
	*/
	public static String getConstant(byte[] constant){
		try {
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawConstantKey = AESCipher.decryptSynchronous(masterKey, CONSTANT_KEY);
			SecretKey constantKey = AESKeyGenerator.generateKeyFromRaw(rawConstantKey);
			byte[] plainText =  AESCipher.decryptSynchronous(constantKey, constant);
			return new String(plainText);
		} catch (Exception e) {
			return null;
		}
	}

	/**
	* return null if got any problem 
	*/
	public static byte[] encrypt(byte[] data, boolean isChecksum){
		try{
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if(isChecksum){
				rawKey = AESCipher.decryptSynchronous(masterKey, CHECKSUM_KEY);
			}else{
				rawKey = AESCipher.decryptSynchronous(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] cipherText =  AESCipher.encryptSynchronous(key, data);
			return cipherText;
		}catch(Exception e){
			return null;
		}
	}

	/**
	* return null if got any problem 
	*/
	public static byte[] decrypt(byte[] data, boolean isChecksum){
		try{
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if(isChecksum){
				rawKey = AESCipher.decryptSynchronous(masterKey, CHECKSUM_KEY);
			}else{
				rawKey = AESCipher.decryptSynchronous(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] plainText =  AESCipher.decryptSynchronous(key, data);
			return plainText;
		}catch(Exception e){
			return null;
		}
	}

}
