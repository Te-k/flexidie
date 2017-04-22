package com.vvt.util.test;

import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Arrays;

import junit.framework.Assert;
import android.test.AndroidTestCase;

import com.vvt.crypto.RSAKeyGenerator;

public class RsaKeyGenTest extends AndroidTestCase{
	
	/**
	 * Test generate public key 
	 * and regenerate this public key from its encoded byte data
	 * and compare both encoded byte data.
	 */
	public void testPublicKeyStability(){
		
		//1 crate RSA key generator
		RSAKeyGenerator keyGen = new RSAKeyGenerator();
		
		//2 get public key
		PublicKey pubKey = keyGen.getPublicKey();
		
		//3 regenerate this public key from its encoded bytes
		PublicKey pubKeyClone = RSAKeyGenerator.generatePublicKeyFromRaw(pubKey.getEncoded());
		
		//4 compare both encoded byte data
		assertEquals(true, Arrays.equals(pubKey.getEncoded(), pubKeyClone.getEncoded()));
	}
	
	/**
	 * Test generate private key
	 * and regenerate this private key from its encoded byte data
	 * and compare both encoded byte data.
	 */
	public void testPrivateKeyStability(){
		
		//1 create RSA key generator
		RSAKeyGenerator keyGen = new RSAKeyGenerator();
		
		//2 get private key
		PrivateKey privateKey = keyGen.getPrivateKey();
		
		//3 regenerate this private key from its encoded bytes
		PrivateKey privateKeyClone = RSAKeyGenerator.generatePrivateKeyFromRaw(privateKey.getEncoded());
		
		//4 compare both encoded byte data
		assertEquals(true, Arrays.equals(privateKey.getEncoded(), privateKeyClone.getEncoded()));
	}


	public void testRecreatePublicKeyFromNull(){

		try{
			RSAKeyGenerator.generatePublicKeyFromRaw(null);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){

		}
	}
	
	public void testRecreatePrivateKeyFromNull(){

		try{
			RSAKeyGenerator.generatePrivateKeyFromRaw(null);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){

		}
	}
}
