package com.vvt.encryption;

import net.rim.device.api.crypto.RandomSource;

public class AESKeyGenerator {
	
	private static final byte lenOfAESKey = 16;
	
	public static byte[] generateAESKey() {
		byte[] aesKey = new byte[lenOfAESKey];
		RandomSource.getBytes(aesKey);
		return aesKey;
	}
}
