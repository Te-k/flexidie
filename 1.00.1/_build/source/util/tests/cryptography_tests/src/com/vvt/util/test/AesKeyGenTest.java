package com.vvt.util.test;

import java.util.Arrays;

import javax.crypto.SecretKey;

import junit.framework.Assert;

import android.test.AndroidTestCase;

import com.vvt.crypto.AESKeyGenerator;

public class AesKeyGenTest extends AndroidTestCase{
	
	/**
	 * Test generate AES key 
	 * and regenerate this key from its encoded byte data
	 * and compare both encoded byte data.
	 */
	public void testKeyStability(){

		//1 create AES key
		SecretKey key = AESKeyGenerator.generate();
		
		//2 regenerate this key from its encoded bytes
		SecretKey keyClone = AESKeyGenerator.generateKeyFromRaw(key.getEncoded()); 
		
		//3 compare both encoded byte data
		assertEquals(true, Arrays.equals(key.getEncoded(), keyClone.getEncoded()));
	}
	
	public void testRecreateKeyFromNull(){
		try{
			AESKeyGenerator.generateKeyFromRaw(null); 
			Assert.fail("Should have thrown IllgalArgumentException");
		}catch(IllegalArgumentException e){
			
		}
	}

}
