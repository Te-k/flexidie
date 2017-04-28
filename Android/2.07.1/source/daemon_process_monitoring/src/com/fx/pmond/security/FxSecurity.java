/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.fx.pmond.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity{

	private static final byte[] MASTER_KEY = {92, 112, -89, 119, 113, -66, -104, 23, -85, -33, -89, -87, -66, -59, 21, -35, 0, -101, -128, 24, -124, 40, -45, 45, -49, -46, -120, -77, -78, -62, 29, 90};
	private static final byte[] CONSTANT_KEY = {79, 14, -25, -110, -98, -40, -113, -86, 68, -76, 75, 77, -56, -95, -102, 54, -73, -50, 95, -62, 38, -60, 36, -86, 9, -91, -110, -45, 91, 28, -67, -69};
	private static final byte[] DYNAMIC_KEY = {26, 89, 73, -87, -69, 50, -95, -6, -79, 49, 108, 83, 7, 113, -39, -62, -108, 8, -18, -109, -94, -110, 67, -53, -68, 78, -90, 99, 18, 49, -9, -113};
	private static final byte[] CHECKSUM_KEY = {-59, -57, -33, -2, -77, 93, 58, -114, 75, 25, 50, -68, 70, -85, 17, 107, -45, -83, 20, -90, -90, -103, 95, 119, 122, -67, 29, 126, 97, 75, 94, -116};

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
