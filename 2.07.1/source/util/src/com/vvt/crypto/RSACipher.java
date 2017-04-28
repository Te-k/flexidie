package com.vvt.crypto;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import com.vvt.logger.FxLog;

/**
 * @author tanakharn
 *
 * 1st Refactoring: December 2011
 * : adjust coding style
 */
public class RSACipher {
	
	//Debug Information
	private static final String TAG = "RSACipher";
	
	/**
	 * Encrypt input data using RSA algorithm.
	 * 
	 * @param publicKey
	 * @param input
	 * @return cipher text or null if error.
	 * @throws InvalidKeyException if public key is invalid.
	 */
	public static byte[] encrypt(RSAPublicKey publicKey, byte[] input)throws InvalidKeyException{

		byte[] cipherText = null;
		
		try {
			//1 create Cipher instance
			Cipher cipher = Cipher.getInstance("RSA/None/PKCS1Padding");
			
			//2 initialize cipher with input public key
			cipher.init(Cipher.ENCRYPT_MODE, publicKey);
			
			//3 do encryption
			cipherText = cipher.doFinal(input);
			
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, String.format("> encrypt # Cipher cannot initiate using the specific algorithm\n%s", e.getMessage()));
		} catch (NoSuchPaddingException e) {
			FxLog.e(TAG, String.format("> encrypt # Cipher cannot initiate with specific padding method\n%s", e.getMessage()));
			
		} catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> encrypt # Public key is invalid\n%s", e.getMessage()));
			throw e;
			
		}catch (IllegalBlockSizeException e) {
			FxLog.e(TAG, String.format("> encrypt # Block size is invalid\n%s", e.getMessage()));
		} catch (BadPaddingException e) {
			FxLog.e(TAG, String.format("> encrypt # Bad padding\n%s", e.getMessage()));
		}
		
		return cipherText;
	}
	
	/**
	 * Decipher input cipher data using RSA algorithm
	 * 
	 * @param privateKey
	 * @param cipherText
	 * @return
	 * @throws InvalidKeyException
	 */
	public static byte[] decrypt(RSAPrivateKey privateKey, byte[] cipherText)throws InvalidKeyException{
		
		byte[] plainText = null;

		try {
			//1 create Cipher instance
			Cipher cipher = Cipher.getInstance("RSA/None/PKCS1Padding");
			
			//2 initialize cipher with input private key
			cipher.init(Cipher.DECRYPT_MODE, privateKey);
			
			//3 do decryption
			plainText = cipher.doFinal(cipherText);
			
		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, String.format("> decrypt # Cipher cannot initiate using specific algorithm\n%s", e.getMessage()));
		} catch (NoSuchPaddingException e) {
			FxLog.e(TAG, String.format("> decrypt # Cipher cannot initiate with specific padding method\n%s", e.getMessage()));
			
		}catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> decrypt # Private key is invalid\n%s", e.getMessage()));
			throw e;
		
		}catch (IllegalBlockSizeException e) {
			FxLog.e(TAG, String.format("> decrypt # Block size is invalid\n%s", e.getMessage()));
		} catch (BadPaddingException e) {
			FxLog.e(TAG, String.format("> decrypt # Bad padding\n%s", e.getMessage()));
		}

		
		return plainText;
	}
}
