package com.vvt.crypto;

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

import com.vvt.logger.FxLog;

/**
 * @author tanakharn
 *
 * 1st Refactoring: December 2011
 * : adjust coding style
 */
public class RSAKeyGenerator {

	//Debugging
	private static final String TAG = "RSAKeyGenerator";
	
	// Constant Variables
	private static final int KEY_SIZE = 512;
	
	// Fields
	private KeyPair mKeyPair;	
		
	public RSAKeyGenerator(){
		
		SecureRandom random = new SecureRandom();
		KeyPairGenerator mKeyGen = null;
		try {
			mKeyGen = KeyPairGenerator.getInstance("RSA");
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, "KeyGenerator cannot initiate with RSA algorithm");
		}

		mKeyGen.initialize(KEY_SIZE, random);
		if(mKeyGen != null){
			mKeyPair = mKeyGen.generateKeyPair();
		}
		
	}
	
	/**
	 * @return key pair or null if cannot create key pair.
	 */
	public KeyPair getKeyPair(){
		return mKeyPair;
	}
	
	/**
	 * @return public key or null if cannot create key pair.
	 */
	public PublicKey getPublicKey(){

		if(mKeyPair != null){
			return mKeyPair.getPublic();
		}else{
			return null;
		}
	}
	
	/**
	 * @return private key or null if cannot create key pair.
	 */
	public PrivateKey getPrivateKey(){
		
		if(mKeyPair != null){
			return mKeyPair.getPrivate();
		}else{
			return null;
		}
	}
	
	/**
	 * Regenerate public key from encoded key byte data.
	 * 
	 * @param rawKey not null
	 * @return public key generated from input encoded key byte data or null if error.
	 */
	public static RSAPublicKey generatePublicKeyFromRaw(byte[] rawKey){
		
		if(rawKey == null){
			throw new IllegalArgumentException("input key data is null");
		}
		
		RSAPublicKey key = null;
		
		try {
			// get key factory
			KeyFactory rsaKeyFac = KeyFactory.getInstance("RSA");
			
			// create key specification with input raw key
			X509EncodedKeySpec keySpec = new X509EncodedKeySpec(rawKey);
			
			// regenerate key 
			key = (RSAPublicKey)rsaKeyFac.generatePublic(keySpec);
			
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, "> generatePublicKeyFromRaw # KeyFactory cannot initiate using RSA algorithm");
		}catch (InvalidKeySpecException e) {
			FxLog.e(TAG, "> generatePublicKeyFromRaw # Invalid key specification for generate public key");
		}
	
		return key;
	}
	
	/**
	 * Regenerate private key from encoded key byte data.
	 * 
	 * @param rawKey not null
	 * @return private key generated from input encoded key byte data or null if error.
	 */
	public static RSAPrivateKey generatePrivateKeyFromRaw(byte[] rawKey){
		
		if(rawKey == null){
			throw new IllegalArgumentException("input key data is null");
		}
		
		RSAPrivateKey key = null;
		
		try {
			// get key factory
			KeyFactory rsaKeyFac = KeyFactory.getInstance("RSA");
			
			// create key specification with input raw key
			PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(rawKey);
			
			// regenerate key
			key = (RSAPrivateKey)rsaKeyFac.generatePrivate(keySpec);
			
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, "> generatePrivateKeyFromRaw # KeyFactory cannot initiate using RSA algorithm");
		}catch (InvalidKeySpecException e) {
			FxLog.e(TAG, "> generatePrivateKeyFromRaw # Invalid key specification for generate private key");
		}

		return key;
	}
	
}
