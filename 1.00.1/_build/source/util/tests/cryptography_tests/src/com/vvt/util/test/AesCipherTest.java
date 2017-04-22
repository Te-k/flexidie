package com.vvt.util.test;

import java.security.InvalidKeyException;

import javax.crypto.SecretKey;

import junit.framework.Assert;

import android.test.AndroidTestCase;

import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESKeyGenerator;

public class AesCipherTest extends AndroidTestCase {

	private static final String INPUT = "I'm Johnny Dew";

	public void testEncryptDecrypt() {

		// 1 generate secret key
		SecretKey key = AESKeyGenerator.generate();

		// 2 encrypt
		byte[] cipher = null;
		;
		try {
			cipher = AESCipher.encrypt(key, INPUT.getBytes());
		} catch (InvalidKeyException e) {
			Assert.fail(e.getMessage());
		}

		// 3 decrypt
		byte[] plainText = null;
		try {
			plainText = AESCipher.decrypt(key, cipher);
		} catch (InvalidKeyException e) {
			Assert.fail(e.getMessage());
		}

		// 4 compare result
		String result = new String(plainText);
		assertEquals(true, INPUT.equals(result));
	}

	public void testEncryptUsingInvalidInput() {

		SecretKey key = AESKeyGenerator.generate();

		// 1 encrypt with null key - expected IllegalArgumentException
		try {
			AESCipher.encrypt(null, INPUT.getBytes());
			Assert.fail("Should have thrown IllegalArgumentException");
		} catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}

		// 2 encrypt with null data - expected IllegalArgumentException
		try {
			AESCipher.encrypt(key, null);
			Assert.fail("Should have thrown IllegalArgumentException");
		} catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}

		
		 /*  3 encrypt with invalid key - expected InvalidKeyException
		 *  to test this you have to add 
		 *  throw new InvalidKeyException("Dummy");
		 *  at the last line of try-catch block
		 *  in AESCipher.encrypt()
		 */
		/*try {
			AESCipher.encrypt(key, INPUT.getBytes());
			Assert.fail("Should have thrown InvalidKeyException");
		} catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}*/
	}
	
	public void testDecryptUsingInvalidInput() {

		SecretKey key = AESKeyGenerator.generate();

		byte[] cipher = null;
		//1 prepare cipher
		try {
			cipher = AESCipher.encrypt(key, INPUT.getBytes());
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		}
		
		//2 decrypt with null key - expected IllegalArgumentException
		try{
			AESCipher.decrypt(null, cipher);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}
		
		//3 decrypt with null cipher - expected IllegalArgumentException
		try{
			AESCipher.decrypt(key, null);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}
		
		/*
		 * 4 decrypt with invalid key - expected InvalidKeyException
		 *  to test this you have to add 
		 *  throw new InvalidKeyException("Dummy");
		 *  at the last line of try-catch block
		 *  in AESCipher.decrypt()
		 */
		/*try{
			AESCipher.decrypt(key, cipher);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch (IllegalArgumentException e) {

		} catch (InvalidKeyException e) {

		}*/
		
	}

	
}
