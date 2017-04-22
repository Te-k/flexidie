package com.vvt.util.test;

import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;

import android.test.AndroidTestCase;

import com.vvt.crypto.RSACipher;
import com.vvt.crypto.RSAKeyGenerator;

public class RsaCipherTest extends AndroidTestCase{
	
	public void testEncryptDecrypt(){
		
		//1 prepare key pair
		RSAKeyGenerator keyGen = new RSAKeyGenerator();
		KeyPair keyPair = keyGen.getKeyPair();
				
		//2 encrypt & decrypt
		String input = "I'm Johnny Dew";
		String output = null;
		try {
			byte[] cipher = RSACipher.encrypt((RSAPublicKey) keyPair.getPublic(), input.getBytes());
			byte[] plainText = RSACipher.decrypt((RSAPrivateKey) keyGen.getPrivateKey(), cipher);
			output = new String(plainText);
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		}

		//3 compare result
		assertEquals(true, input.equals(output));
		
	}

}
