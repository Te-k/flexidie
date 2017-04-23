/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.fx.maind.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity{

	private static final byte[] MASTER_KEY = {-67, -46, 4, -5, -14, -82, 5, -32, -72, 93, 35, -102, -84, -70, -38, 124, 52, 15, -34, -4, -29, 93, 115, 29, 18, 37, -30, 121, -67, -2, -19, 84};
	private static final byte[] CONSTANT_KEY = {-99, 46, 117, 68, 113, -114, 89, 75, 59, 84, 76, -58, 79, 75, 97, -53, 92, -69, -37, -113, 55, 110, -19, 10, -97, 52, -124, 77, 38, 102, -60, 126};
	private static final byte[] DYNAMIC_KEY = {-64, 84, 66, 104, 3, 87, -50, 56, 6, 103, -124, 53, 36, -119, -19, 44, -14, 110, 75, -113, -115, 33, -80, 32, 50, -65, 6, -100, 51, -126, -37, 28};
	private static final byte[] CHECKSUM_KEY = {-124, 48, 76, 9, 3, 100, 35, -63, 60, 28, 93, -21, -38, -6, 50, -50, -62, -97, -107, -108, -79, 107, -17, 95, 18, 71, 94, 110, -91, -31, -114, 72};

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
