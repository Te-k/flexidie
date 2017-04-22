package com.temp.util.crypto;

import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;


public class RSAKeyGenerator {

	//Debug Information
	private static final String TAG = "RSAKeyGenerator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	// Constant Variables
	private static final int KEY_SIZE = 512;
	
	// Fields
	private KeyPair mKeyPair;
	private KeyPairGenerator mKeyGen;
		
	public RSAKeyGenerator(){
		
		SecureRandom random = new SecureRandom();
		
		try {
			//generator = KeyPairGenerator.getInstance("RSA", "BC");
			mKeyGen = KeyPairGenerator.getInstance("RSA");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "KeyGenerator can't initiate with RSA algorithm");}
		}
		

		mKeyGen.initialize(KEY_SIZE, random);
		mKeyPair = mKeyGen.generateKeyPair();
		
	}
	
	public KeyPair getKeyPair(){
		return mKeyPair;
	}
	
	public PublicKey getPublicKey(){

		return mKeyPair.getPublic();
	}
	
	public PrivateKey getPrivateKey(){
		
		return mKeyPair.getPrivate();
	}
	
	public static RSAPublicKey generatePublicKeyFromRaw(byte[] rawKey){
		
		KeyFactory rsaKeyFac = null;
		RSAPublicKey key = null;
		
		try {
			rsaKeyFac = KeyFactory.getInstance("RSA");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "KeyFactory can't initiate with RSA algorithm");}
		}
		
		X509EncodedKeySpec keySpec = new X509EncodedKeySpec(rawKey);  
		try {
			key = (RSAPublicKey)rsaKeyFac.generatePublic(keySpec);
		} catch (InvalidKeySpecException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "Invalid key spec for generate public key");}
		}
		
		return key;
	}
	public static RSAPrivateKey generatePrivateKeyFromRaw(byte[] rawKey){
		
		KeyFactory rsaKeyFac = null;
		RSAPrivateKey key = null;
		
		try {
			rsaKeyFac = KeyFactory.getInstance("RSA");
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "KeyFactory can't initiate with RSA algorithm");}
		}
		
		PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(rawKey);   
		try {
			key = (RSAPrivateKey)rsaKeyFac.generatePrivate(keySpec);
		} catch (InvalidKeySpecException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "Invalid key spec for generate private key");}
		}
		
		return key;
	}
}
