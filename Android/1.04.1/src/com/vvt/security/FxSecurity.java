/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.vvt.security;
import javax.crypto.SecretKey;
import com.vvt.util.crypto.*;
import java.nio.ByteBuffer;

public class FxSecurity{

	private static final byte[] MASTER_KEY = {-87, 29, 76, 97, 114, -126, -122, -79, -42, 32, 23, -123, -83, 110, -24, -42, -61, -24, -50, 74, -83, -70, -25, -80, -127, 77, 72, -49, 80, 49, 125, -82};
	private static final byte[] CONSTANT_KEY = {-31, 9, 43, -37, 4, -49, -25, -11, -64, -30, 111, 37, 98, -34, -94, 124, -14, 8, 42, 99, -12, 113, 55, -21, -69, 41, -106, 34, -78, 35, -51, -118};
	private static final byte[] DYNAMIC_KEY = {-128, -99, -70, -21, 40, 95, -80, -70, -117, 88, -57, 29, 125, -124, -74, 31, 64, 111, -98, -24, -30, -56, 34, 123, -80, -114, 36, 57, -124, -56, 78, 87};
	private static final byte[] CHECKSUM_KEY = {26, -83, -41, -48, -72, 67, -32, 32, -97, -45, 51, 97, -105, 65, 91, -99, -103, 113, 127, -107, 53, 114, -103, 77, -105, 84, 3, -44, -71, 89, -57, -126};

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
