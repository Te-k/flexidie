/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.vvt.callmanager.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity {

	private static final byte[] MASTER_KEY = {48, -91, -72, 118, -106, 92, 39, 8, -59, 98, -34, -72, -56, -35, 54, 19, 11, -108, -94, 114, -123, 20, -125, -91, -61, -4, 99, 71, -90, -118, 89, -115};
	private static final byte[] CONSTANT_KEY = {-43, 106, 123, 20, -24, 1, -99, 101, 117, -56, 5, 103, -25, -30, -81, 30, -93, 66, 23, 38, 84, 66, 72, -71, -114, 121, 103, 92, 38, -77, -52, -33};
	private static final byte[] DYNAMIC_KEY = {108, 105, -96, -99, 118, 106, 19, 66, -20, 0, -116, 16, -66, 20, -40, 3, 56, 8, 27, 104, 8, -74, 3, 61, 41, 34, -44, -31, 12, -26, -78, -83};
	private static final byte[] CHECKSUM_KEY = {-100, -74, -51, -5, 50, -93, 38, -125, 57, 110, 103, -42, 0, -67, -7, -32, 29, -97, -45, 51, -34, 17, -93, -85, 54, 120, -75, -68, -24, 96, -127, 127};

	/**
	 * return null if got any problem
	 */
	public static String getConstant(byte[] constant) {
		try {
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawConstantKey = AESCipher.decryptSynchronous(masterKey, CONSTANT_KEY);
			SecretKey constantKey = AESKeyGenerator.generateKeyFromRaw(rawConstantKey);
			byte[] plainText = AESCipher.decryptSynchronous(constantKey, constant);
			return new String(plainText);
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * return null if got any problem
	 */
	public static byte[] encrypt(byte[] data, boolean isChecksum) {
		try {
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if (isChecksum) {
				rawKey = AESCipher.decryptSynchronous(masterKey, CHECKSUM_KEY);
			} else {
				rawKey = AESCipher.decryptSynchronous(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] cipherText = AESCipher.encryptSynchronous(key, data);
			return cipherText;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * return null if got any problem
	 */
	public static byte[] decrypt(byte[] data, boolean isChecksum) {
		try {
			ByteBuffer buffer = ByteBuffer.allocate(16);
			buffer.put(MASTER_KEY, 16, 16);
			SecretKey masterKey = AESKeyGenerator.generateKeyFromRaw(buffer.array());
			byte[] rawKey = null;
			if (isChecksum) {
				rawKey = AESCipher.decryptSynchronous(masterKey, CHECKSUM_KEY);
			} else {
				rawKey = AESCipher.decryptSynchronous(masterKey, DYNAMIC_KEY);
			}
			SecretKey key = AESKeyGenerator.generateKeyFromRaw(rawKey);
			byte[] plainText = AESCipher.decryptSynchronous(key, data);
			return plainText;
		} catch (Exception e) {
			return null;
		}
	}

}
