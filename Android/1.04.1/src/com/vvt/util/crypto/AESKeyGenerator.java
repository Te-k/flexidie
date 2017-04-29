package com.vvt.util.crypto;

import java.security.NoSuchAlgorithmException;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 10-May-2010 4:55:38 PM
 */
public class AESKeyGenerator {

	//Debug Information
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	//Constant variables
	private static final int KEY_SIZE = 128;	// 16 bytes
	//Fields
	//private static SecretKey key;
	//private static KeyGenerator generator;

	/*
	public AESKeyGenerator(){
		try {
			generator = KeyGenerator.getInstance("AES");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){System.out.println("KeyGenerator can't initiate with AES algorithm");}
		}
		generator.init(KEY_SIZE);	
	}
	*/
	public static SecretKey generate(){
		KeyGenerator generator = null;
		try {
			generator = KeyGenerator.getInstance("AES");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){System.out.println("KeyGenerator can't initiate with AES algorithm");}
		}
		generator.init(KEY_SIZE);
		
		return generator.generateKey();
	}
	
	public static SecretKey generateKeyFromRaw(byte[] rawKey){		
		SecretKey key = new SecretKeySpec(rawKey, "AES");
		return key;
	}
	/*
	public SecretKey generateKeyFromRaw(byte[] rawKey){
		try {
			generator = KeyGenerator.getInstance("AES");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){System.out.println("KeyGenerator can't initiate with AES algorithm");}
		}
		generator.init(KEY_SIZE);
		
		KeyFactory rsaKeyFac = null;
		SecretKey key = null;
		
		try {
			rsaKeyFac = KeyFactory.getInstance("AES");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		
		X509EncodedKeySpec keySpec = new X509EncodedKeySpec(rawKey);  
		try {
			key = (SecretKey)rsaKeyFac.generatePublic(keySpec);		//may be not this method
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		}
		
		return key;
	}
	*/
	/*
	// is this method generate unique key each time called?
	public SecretKeySpec generate(){
	     // Generate the secret key specs.
		SecretKey skey = generator.generateKey();
	    byte[] raw = skey.getEncoded();
	    SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");

	    return skeySpec;
	}
	*/
	


}