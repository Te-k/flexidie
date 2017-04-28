package com.temp.util.crypto;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

public class RSACipher {
	
	//Debug Information
	private static final String TAG = "RSACipher";
	private static final boolean DEBUG = Customization.DEBUG ? true : false;
	
	public static byte[] encrypt(RSAPublicKey publicKey, byte[] input)throws InvalidKeyException{
		Cipher cipher = null;
		try {
			cipher = Cipher.getInstance("RSA/None/PKCS1Padding");
		} catch (NoSuchAlgorithmException e) {
			if(DEBUG){FxLog.e(TAG, "cipher can't initiate with RAS/None/PKCS1Padding algorithm");}
		} catch (NoSuchPaddingException e) {
			if(DEBUG){FxLog.e(TAG, "cipher can't initiate with PKCS1Padding");}
		}
		try {
			cipher.init(Cipher.ENCRYPT_MODE, publicKey);
		} catch (InvalidKeyException e) {
			throw new InvalidKeyException(TAG+": Invalid Public Key!", e);
		}
		byte[] cipherText = null;
		try {
			cipherText = cipher.doFinal(input);
		} catch (IllegalBlockSizeException e) {
			if(DEBUG){FxLog.e(TAG, "encrypt operation -> size of the remaining resulting bytes is not a multiple of the cipher block size");}
		} catch (BadPaddingException e) {
			if(DEBUG){FxLog.e(TAG, "encrypt operation -> bad padding in remaining block");}
		}
		
		return cipherText;
	}
	
	public static byte[] decrypt(RSAPrivateKey privateKey, byte[] cipherText)throws InvalidKeyException{
		Cipher cipher = null;
		try {
			cipher = Cipher.getInstance("RSA/None/PKCS1Padding");
		} catch (NoSuchAlgorithmException e1) {
			if(DEBUG){FxLog.e(TAG, "cipher can't initiate with RAS/None/PKCS1Padding algorithm");}
		} catch (NoSuchPaddingException e1) {
			if(DEBUG){FxLog.e(TAG, "cipher can't initiate with PKCS1Padding");}
		}
		try {
			cipher.init(Cipher.DECRYPT_MODE, privateKey);
		} catch (InvalidKeyException e) {
			throw new InvalidKeyException(TAG+": Invalid Public Key!", e);
		}
		byte[] plainText = null;
		try {
			plainText = cipher.doFinal(cipherText);
		} catch (IllegalBlockSizeException e) {
			if(DEBUG){FxLog.e(TAG, "decrypt operation -> size of the remaining resulting bytes is not a multiple of the cipher block size");}
		} catch (BadPaddingException e) {
			if(DEBUG){FxLog.e(TAG, "decrypt operation -> bad padding in remaining block");}
		}
		
		return plainText;
	}
}
