/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.fx.pmond.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity{

	private static final byte[] MASTER_KEY = {80, 41, -11, 66, -66, -67, 125, 122, -8, 114, 83, 80, -117, 124, -114, -46, -95, 6, 41, 18, -62, -75, -35, 101, 52, -96, 31, -127, -69, 73, 25, -15};
	private static final byte[] CONSTANT_KEY = {16, -48, -92, 20, -27, 45, -55, 81, 124, -12, 50, 64, -63, 99, -10, -25, -84, 38, 125, -78, 27, 105, 29, 79, -26, 120, 47, -101, 112, -109, -117, -5};
	private static final byte[] DYNAMIC_KEY = {-13, 72, -38, -83, -92, -34, 24, 124, -43, -57, 121, -77, 59, -81, -19, -34, -91, -98, -104, -63, 24, 59, 37, -75, 85, 87, -35, -126, -122, 105, -101, 68};
	private static final byte[] CHECKSUM_KEY = {31, -11, 2, 41, -87, -107, -61, -10, 71, -58, -77, 51, 86, 83, 53, -55, 37, 20, 71, -61, 20, -47, 81, 124, 77, 80, 112, 116, 77, 20, -70, -70};

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
