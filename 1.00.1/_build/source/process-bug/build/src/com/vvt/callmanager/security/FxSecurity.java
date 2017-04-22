/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.vvt.callmanager.security;

import java.nio.ByteBuffer;

import javax.crypto.SecretKey;

import com.temp.util.crypto.AESCipher;
import com.temp.util.crypto.AESKeyGenerator;

public class FxSecurity {

	private static final byte[] MASTER_KEY = { -37, 23, -13, 31, -125, -79,
			106, -82, 66, 92, 28, 56, 97, 65, -112, -38, -96, -35, 58, -125,
			-89, 19, 36, 124, -28, -64, -28, 82, -101, 22, -17, -112 };
	private static final byte[] CONSTANT_KEY = { 104, -67, -125, 71, 121, 111,
			-32, -28, -90, 4, -61, -36, -70, -82, -35, -29, -103, -42, -110,
			45, 40, 121, 87, 90, 68, -51, 80, -61, -70, -86, -21, 42 };
	private static final byte[] DYNAMIC_KEY = { 45, -106, 24, -116, -49, 6, 60,
			-67, 74, -33, 59, -67, 112, -3, -53, 46, 126, 54, 64, -88, 115, 66,
			66, -15, 52, -98, 66, 60, -108, -42, -97, -35 };
	private static final byte[] CHECKSUM_KEY = { -55, 98, 55, 60, -97, -127,
			-75, 27, 18, -46, 98, -119, -88, 92, 40, -35, -4, -70, -94, -13,
			122, -20, 55, -83, 65, 16, -109, -29, 2, -13, -80, 44 };

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
