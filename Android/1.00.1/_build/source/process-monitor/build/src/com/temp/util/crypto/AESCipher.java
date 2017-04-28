package com.temp.util.crypto;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 10-May-2010 5:29:44 PM
 */
public class AESCipher extends Thread {

	//Debug Information
	private static final String TAG = "AESCipher";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Fileds
	private static final int BUFFER_SIZE = 1024;
	private static Cipher mCipher;
	private static final IvParameterSpec CBC_SALT = new IvParameterSpec(
            new byte[] { 7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43 } );
	private SecretKey mKey;
	private String mInputFilePath;
	private FileInputStream mFileIn;
	private String mOutputFilePath;
	private FileOutputStream mFileOut;
	private AESCipherListener mListener;
	private boolean mIsEncrypt;

	public AESCipher(){
		// initiate cipher
		 try {
			mCipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with AES/CBC algorithm");}
		} catch (NoSuchPaddingException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with PKCS5Padding");}
		}
	}
	
	public static byte[] encryptSynchronous(SecretKey key, byte[] data) throws InvalidKeyException{
		//1 initiate cipher
		 try {
			mCipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with AES/CBC algorithm");}
		} catch (NoSuchPaddingException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with PKCS5Padding");}
		}
		//2 initial cipher
		try {
			mCipher.init(Cipher.ENCRYPT_MODE, key, CBC_SALT);
		} catch (InvalidKeyException e1) {
			throw new InvalidKeyException(TAG+": Key Invalid in encrypt operation!");
		} catch (InvalidAlgorithmParameterException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt byte[] operation -> some thing wrong with initial vector");}
		}
		
		//3 encrypt
		byte[] cipherText = null;
		try {
			cipherText = mCipher.doFinal(data);
		} catch (IllegalBlockSizeException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt byte[] operation -> size of the resulting bytes is not a multiple of the cipher block size");}
		} catch (BadPaddingException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt byte[] operation -> bad padding");}
		}
		
		return cipherText;
	}

	public static byte[] decryptSynchronous(SecretKey key, byte[] data)throws InvalidKeyException{
		//1 initiate cipher
		 try {
			mCipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
		} catch (NoSuchAlgorithmException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with AES/CBC algorithm");}
		} catch (NoSuchPaddingException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "cipher can't init with PKCS5Padding");}
		}
		//2 Initialize the same cipher for decryption with Initial Vector
		try {
			//cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));
			mCipher.init(Cipher.DECRYPT_MODE, key, CBC_SALT);
		} catch (InvalidKeyException e1) {
			throw new InvalidKeyException(TAG+": Key Invalid in decrypt operation!");
		} catch (InvalidAlgorithmParameterException e1) {
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt byte[] operation -> some thing wrong with initial vector");}
		}
		
		//3 decrypt
		byte[] plainText = null;
		try {
			plainText = mCipher.doFinal(data);
		} catch (IllegalBlockSizeException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt byte[] operation -> size of the resulting bytes is not a multiple of the cipher block size");}
		} catch (BadPaddingException e) {
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt byte[] operation -> bad padding");}
		}
		
		return plainText;
	}

	public void encryptASynchronous(SecretKey key, String inputFilePath, String outputFilePath, AESCipherListener listener){// throws FileNotFoundException, SecurityException {
		mKey = key;
		mInputFilePath = inputFilePath;
		mOutputFilePath = outputFilePath;
		mListener = listener;
		mIsEncrypt = true;
		
		this.start();
	}

	public void decryptASynchronous(SecretKey key, String inputFilePath, String outputFilePath, AESCipherListener listener){// throws FileNotFoundException, SecurityException{
		mKey = key;
		mInputFilePath = inputFilePath;
		mOutputFilePath = outputFilePath;
		mListener = listener;
		mIsEncrypt = false;
		
		this.start();
	}

	public int getBlockSize(){
		return mCipher.getBlockSize();
	}
	
	@Override
	public void run(){
		if(mIsEncrypt){
			runEncryptASynchronous();			
		}else{
			runDecryptASynchronous();			
		}
	}
	
	private void runEncryptASynchronous(){
		if(LOCAL_LOGV){FxLog.v(TAG, "AESCipher Thread running in Encryption Mode");}
		
		//1 prepare Listener
		AESEncryptListener listener = (AESEncryptListener) mListener;
		
		//2 open files
		try {
			mFileIn = new FileInputStream(mInputFilePath);
			mFileOut = new FileOutputStream(mOutputFilePath);
		} catch (FileNotFoundException e) {
			listener.onAESEncryptError(e);
			if(LOCAL_LOGE){FxLog.e(TAG, e.getMessage());}
			return;
		}
		
		
		//3 Initialize cipher
		 try {
			mCipher.init(Cipher.ENCRYPT_MODE, mKey, CBC_SALT);
		} catch (InvalidKeyException e) {
			listener.onAESEncryptError(e);	
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt InputStream operation -> Invalid Key");}
			return;
		} catch (InvalidAlgorithmParameterException e) {
			listener.onAESEncryptError(e);	
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt InputStream operation -> some thing wrong with initial vector");}
			return;
		}
		//4 initiate CipherInputStream and buffer
		CipherInputStream cis = new CipherInputStream(mFileIn, mCipher);
		byte[] buffer = new byte[BUFFER_SIZE];
		
		//5 read and encrypt first byte from input
		int readCount = 0;
		try {
			readCount = cis.read(buffer);
		} catch (IOException e) {
			listener.onAESEncryptError(e);
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt stream operation -> IOException while encrypting first bytes");}
			return;
		}
		
		//6 writing cipher to output and continue read/encrypt from input
		while(readCount != -1){
			try {
				mFileOut.write(buffer, 0, readCount);
			} catch (IOException e) {
				listener.onAESEncryptError(e);
				if(LOCAL_LOGE){FxLog.e(TAG, "encrypt stream operation -> IOException while writing to output file");}
				return;
			}
			try {
				readCount = cis.read(buffer);
			} catch (IOException e) {
				listener.onAESEncryptError(e);
				if(LOCAL_LOGE){FxLog.e(TAG, "encrypt stream operation -> IOException while encrypting");}
				return;
			}
		}
		
		//7 close all streams
		try {
			cis.close();
			mFileOut.close();
		} catch (IOException e) {
			//listener.onAESEncryptError(e);	//we not notify closing stream exception to caller, since the encryption already finished
												// thus everything should be OK
			if(LOCAL_LOGE){FxLog.e(TAG, "encrypt stream operation -> IOException while closing streams");}
			//return;
		}
		
		//8 call back to caller
		//debug msg
		if(LOCAL_LOGV)FxLog.v(TAG, "AESCipher Thread is sending data back to caller"); 
		listener.onAESEncryptSuccess(mOutputFilePath);
  
		//debug msg
		if(LOCAL_LOGV)FxLog.v(TAG, "AESCipher Thread is now saying Good Bye");
	}
	
	private void runDecryptASynchronous(){
		if(LOCAL_LOGV){FxLog.v(TAG, "AESCipher Thread running in Decryption Mode");}		
		
		//1 prepare Listener
		AESDecryptListener listener = (AESDecryptListener) mListener;
		
		//2 open files
		try {
			mFileIn = new FileInputStream(mInputFilePath);
			mFileOut = new FileOutputStream(mOutputFilePath);
		} catch (FileNotFoundException e) {
			listener.onAESDecryptError(e);
			if(LOCAL_LOGE){FxLog.e(TAG, e.getMessage());}
			return;
		}
		
		
		//3 Initialize cipher
		 try {
			mCipher.init(Cipher.DECRYPT_MODE, mKey, CBC_SALT);
			//mCipher.init(Cipher.DECRYPT_MODE, mKey, new IvParameterSpec(iv));
		} catch (InvalidKeyException e) {
			listener.onAESDecryptError(e);	
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt InputStream operation -> Invalid Key");}
			return;
		} catch (InvalidAlgorithmParameterException e) {
			listener.onAESDecryptError(e);
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt InputStream operation -> some thing wrong with initial vector");}
			return;
		}
		
		//4 initiate CipherInputStream and buffer
		CipherInputStream cis = new CipherInputStream(mFileIn, mCipher);
		byte[] buffer = new byte[BUFFER_SIZE];
		
		//5 read and decrypt first byte from input
		int readCount = 0;
		try {
			readCount = cis.read(buffer);
		} catch (IOException e) {
			listener.onAESDecryptError(e);
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt stream operation -> IOException while decrypting first byte");}
			return;
		}
		
		//6 writing plain text to output and continue read/decrypt from input
		while(readCount != -1){
			try {
				mFileOut.write(buffer, 0, readCount);
			} catch (IOException e) {
				listener.onAESDecryptError(e);
				if(LOCAL_LOGE){FxLog.e(TAG, "decrypt stream operation -> IOException while writing to output file");}
				return;
			}
			try {
				readCount = cis.read(buffer);
			} catch (IOException e) {
				listener.onAESDecryptError(e);
				if(LOCAL_LOGE){FxLog.e(TAG, "decrypt stream operation -> IOException while decrypting");}
				return;
			}
		}
		
		//7 close all stream
		try {
			cis.close();
			mFileOut.close();
		} catch (IOException e) {
			//listener.onAESDecryptError(new IOException());	//we not notify closing stream exception to caller, since the encryption already finished
																// thus everything should be OK
			if(LOCAL_LOGE){FxLog.e(TAG, "decrypt stream operation -> IOException while closing streams");}
			//return;
		}
		
		//8 call back to caller
		//debug msg
		if(LOCAL_LOGV)FxLog.v(TAG, "AESCipher Thread is sending data back to caller");
		listener.onAESDecryptSuccess(mOutputFilePath);
  
		//debug msg
		if(LOCAL_LOGV)FxLog.v(TAG, "AESCipher Thread is now saying Good Bye");
		
	}
	
	
	
}