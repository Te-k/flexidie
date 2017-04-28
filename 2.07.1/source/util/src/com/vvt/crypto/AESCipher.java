package com.vvt.crypto;

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

import com.vvt.async.AsyncCallback;
import com.vvt.async.NullListenerException;
import com.vvt.logger.FxLog;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 10-May-2010 5:29:44 PM
 * 
*  1st Refactoring: December 2011
 * : adjust coding style,
 * 	 improve Threading by using AsyncCallback
 */
public class AESCipher extends AsyncCallback<AESCipherListener> {

	//Debug Information
	private static final String TAG = "AESCipher";

	
	//Fileds
	private static final int BUFFER_SIZE = 1024;
	private static final IvParameterSpec CBC_SALT = new IvParameterSpec(
            new byte[] { 7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43 } );
	/*
	 * Constants
	 */
	private static final int MODE_ENCRYPT = 1;
	private static final int MODE_DECRYPT = 2;
	private static final int CALL_BACK_ENCRYPT_ERROR = 1;
	private static final int CALL_BACK_ENCRYPT_SUCCESS = 2;
	private static final int CALL_BACK_DECRYPT_ERROR = 3;
	private static final int CALL_BACK_DECRYPT_SUCCESS = 4;
	
	
	private boolean mWorkInProgress;
	private int mWorkingMode;
	private SecretKey mKey;
	private String mInputFilePath;
	private String mOutputFilePath;
	private AESCipherListener mListener;
	
	/**
	 * Encrypt input file and store output cipher into output file.
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE
	 * 
	 * @param key secret key for encrypt - cannot be null.
	 * @param inputFilePath absolute path to input file - cannot be null.
	 * @param outputFilePath absolute path to output file - cannot be null.
	 * @param listener AESEncryptListener - null is allowed.
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public synchronized boolean encrypt(SecretKey key, String inputFilePath, String outputFilePath, AESEncryptListener listener){
		if(!mWorkInProgress){
			mWorkInProgress = true;
			
			FxLog.d(TAG, "!encrypt");
			
			//validate input
			if(key == null){
				FxLog.e(TAG, "> encrypt # Secret Key cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Secret Key cannot be NULL");
			}
			if(inputFilePath == null){
				FxLog.e(TAG, "> encrypt # Input file path cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Input file path cannot be NULL");
			}
			if(outputFilePath == null){
				FxLog.e(TAG, "> encrypt # Output file path cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Output file path cannot be NULL");
			}

			// set parameters
			mKey = key;
			mInputFilePath = inputFilePath;
			mOutputFilePath = outputFilePath;
			mListener = listener;
			mWorkingMode = MODE_ENCRYPT;
			
			//grab caller Thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "> compress # NullListenerException");
				}
			}
			
			// start executor			
			Executor executor = new Executor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			FxLog.e(TAG, "> encrypt # Previous request is in progress, skip incoming request");
			return false;
		}
	}
	
	/**
	 * Decipher input file and store output plain text into output file.
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE.
	 * 
	 * @param key secret key for decrypt - cannot be null.
	 * @param inputFilePath absolute path to input cipher file - cannot be null.
	 * @param outputFilePath absolute path to output plain text file - cannot be null.
	 * @param listener AESDecryptListener - null is allowed.
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public synchronized boolean decrypt(SecretKey key, String inputFilePath, String outputFilePath, AESDecryptListener listener){
		if(!mWorkInProgress){
			mWorkInProgress = true;
			
			FxLog.d(TAG, "!decrypt");
			
			//validate input
			if(key == null){
				FxLog.e(TAG, "> decrypt # Secret Key cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Secret Key cannot be NULL");
			}
			if(inputFilePath == null){
				FxLog.e(TAG, "> decrypt # Input file path cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Input file path cannot be NULL");
			}
			if(outputFilePath == null){
				FxLog.e(TAG, "> decrypt # Output file path cannot be NULL");
				mWorkInProgress = false;
				throw new IllegalArgumentException("Output file path cannot be NULL");
			}
						
			// set parameters
			mKey = key;
			mInputFilePath = inputFilePath;
			mOutputFilePath = outputFilePath;
			mListener = listener;
			mWorkingMode = MODE_DECRYPT;
			
			//grab caller Thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "> compress # NullListenerException");
				}
			}
			
			// start executor			
			Executor executor = new Executor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			FxLog.e(TAG, "> decrypt # Previous request is in progress, skip incoming request");
			return false;
		}
	}
	
	private class Executor extends Thread{
		
		
		@Override
		public void run(){
			FxLog.d(TAG, String.format("Executor > run # Executor is running with Thread ID: %d", Thread.currentThread().getId()));
			
			//choose operation mode
			if(mWorkingMode == MODE_ENCRYPT){
				doEncrypt();
			}else{
				doDecrypt();
			}
			
		}
		
		private void doEncrypt(){
			AESEncryptListener listener = null;
			try {
				
				//1 prepare Listener
				if(mListener != null){
					listener = (AESEncryptListener) mListener;
				}
				
				//2 open files
				FileInputStream fInStream = new FileInputStream(mInputFilePath);		// input plain text file
				FileOutputStream fOutStream = new FileOutputStream(mOutputFilePath);	// output cipher file
				
				//3 prepare Cipher instance
				Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
				
				//4 initialize Cipher
				cipher.init(Cipher.ENCRYPT_MODE, mKey, CBC_SALT);
				
				//5 initiate CipherInputStream and buffer
				CipherInputStream cis = new CipherInputStream(fInStream, cipher);
				byte[] buffer = new byte[BUFFER_SIZE];
				
				//6 encrypt data and write output to file
				int readCount = cis.read(buffer);
				while(readCount != -1){
					fOutStream.write(buffer, 0, readCount);
					readCount = cis.read(buffer);
				}
				
				//7 do final encryption block and close input stream (IOException might be occurred)
				cis.close();
				
				/*
				 * 8 close output stream
				 * We need to close output stream before notify result to caller.
				 * Since caller might use this file.
				 */
				fOutStream.close();
				
				//9 clear working flag
				mWorkInProgress = false;

				//10 notify caller and clear working flag
				if(listener != null){
					mListener = null;
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_SUCCESS, mOutputFilePath);
					listener = null;
				}


			}catch (FileNotFoundException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # File not found\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			}catch (NoSuchAlgorithmException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # Cannot initiate Cipher using the given algorithm\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (NoSuchPaddingException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # Cannot initiate Cipher using the given padding method\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}	
				mWorkInProgress = false;
			} catch (InvalidKeyException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # Secret Key is invalid\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (InvalidAlgorithmParameterException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # IV is invalid\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (IOException e) {
				FxLog.e(TAG, String.format("Executor > doEncrypt # Exception while encryting file\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_ENCRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			}
		}
		
		private void doDecrypt(){
			AESDecryptListener listener = null;
		
			try{
				//1 prepare listener
				if(mListener != null){
					listener = (AESDecryptListener) mListener;
				}
				
				//2 open files
				FileInputStream fInStream = new FileInputStream(mInputFilePath);		// input cipher file
				FileOutputStream fOutStream = new FileOutputStream(mOutputFilePath);	// output plain text file
				
				//3 prepare Cipher instance
				Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
				
				//4 initialize Cipher
				cipher.init(Cipher.DECRYPT_MODE, mKey, CBC_SALT);
				
				//5 initiate CipherInputStream and buffer
				CipherInputStream cis = new CipherInputStream(fInStream, cipher);
				byte[] buffer = new byte[BUFFER_SIZE];
				
				//6 decrypt data and write output to file
				int readCount = cis.read(buffer);
				while(readCount != -1){
					fOutStream.write(buffer, 0, readCount);
					readCount = cis.read(buffer);
				}
				
				//7 do final decryption block and close input stream (IOException might be occurred)
				cis.close();
				
				/*
				 * 8 close output stream
				 * We need to close output stream before notify result to caller.
				 * Since caller might use this file.
				 */
				fOutStream.close();
				
				//9 clear working flag
				mWorkInProgress = false;
				
				//10 notify caller and clear working flag
				if(listener != null){
					mListener = null;
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_SUCCESS, mOutputFilePath);
					listener = null;
				}
				
			
			}catch (FileNotFoundException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # File not found\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			}catch (NoSuchAlgorithmException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # Cannot initiate Cipher using the given algorithm\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (NoSuchPaddingException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # Cannot initiate Cipher using the given padding method\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}	
				mWorkInProgress = false;				
			} catch (InvalidKeyException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # Secret Key is invalid\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (InvalidAlgorithmParameterException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # IV is invalid\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			} catch (IOException e) {
				FxLog.e(TAG, String.format("Executor > doDecrypt # Exception while decryting file\n%s", e.getMessage()));
				if(listener != null){
					invokeAsyncCallback(listener, CALL_BACK_DECRYPT_ERROR, e);
					listener = null;
					mListener = null;
				}
				mWorkInProgress = false;
			}		
			
		}
	}
	
	@Override
	protected void onAsyncCallbackInvoked(AESCipherListener listener, int what, Object... results) {
		FxLog.d(TAG, String.format("> onAsyncCallbackInvoked # Thread ID: %d", Thread.currentThread().getId()));

		/*
		 * CRITICAL - Concurrent Problem!
		 * The reason that we remove async callback here (using caller Thread)
		 * because of the concurrent problem.
		 * If caller thread request for another operation immediately in callback method - for example, call decrypt() in onAESEncryptSuccess(),
		 * and also supply the same listener instance with the past request - normally, the listener instance is the caller's instance
		 * The listener object might be null if we remove async callback in Executor Thread after call invokeAsyncCallback()
		 * since Caller Thread might be faster than Executor and set new request before Executor remove previous listener.
		 */
		removeAsyncCallback(listener);
		
		switch(what){
			case CALL_BACK_ENCRYPT_ERROR :
				AESEncryptListener encryptErrListener = (AESEncryptListener) listener;
				encryptErrListener.onAESEncryptError((Exception) results[0]);
				break;
			
			case CALL_BACK_ENCRYPT_SUCCESS :
				AESEncryptListener encryptSucListener = (AESEncryptListener) listener;
				encryptSucListener.onAESEncryptSuccess((String) results[0]);
				break;
				
			case CALL_BACK_DECRYPT_ERROR :
				AESDecryptListener decryptErrListener = (AESDecryptListener) listener;
				decryptErrListener.onAESDecryptError((Exception) results[0]);
				break;
				
			case CALL_BACK_DECRYPT_SUCCESS :
				AESDecryptListener decryptSucListener = (AESDecryptListener) listener;
				decryptSucListener.onAESDecryptSuccess((String) results[0]);
				break;
		}
		
	}
		
	
	// =================================================== static methods ========================================== //
	
	/**
	 * Encrypt input byte data using AES algorithm.
	 * 
	 * @param key
	 * @param data
	 * @return cipher or null if error.
	 * @throws InvalidKeyException if input secret key is invalid.
	 */
	public static byte[] encrypt(SecretKey key, byte[] data) throws InvalidKeyException{
		
		if(key == null || data == null){
			FxLog.e(TAG, "> encrypt # Input data is null");
			throw new IllegalArgumentException("input is null");
		}
		
		byte[] cipherText = null;
		
		try {
			//1 get Cipher
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			//2 initialize Cipher
			cipher.init(Cipher.ENCRYPT_MODE, key, CBC_SALT);
			//3 do encryption
			cipherText = cipher.doFinal(data);

		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, String.format("> encrypt # cipher connot initialize using specific algorithm\n%s", e.getMessage()));
		} catch (NoSuchPaddingException e) {
			FxLog.e(TAG, String.format("> encrypt # cipher cannot initialize specific padding\n%s", e.getMessage()));

		} catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> encrypt # Secret key is invalid\n%s", e.getMessage()));
			throw e;
		} catch (InvalidAlgorithmParameterException e) {
			FxLog.e(TAG, String.format("> encrypt # Initial Vector is invalid\n%s", e.getMessage()));
		} catch (IllegalBlockSizeException e) {
			FxLog.e(TAG, String.format("> encrypt # Illegal block size\n%s", e.getMessage()));
		} catch (BadPaddingException e) {
			FxLog.e(TAG, String.format("> encrypt # Bad padding\n%s", e.getMessage()));
		}
	
		
		return cipherText;
	}

	/**
	 * Decipher input cipher using AES algorithm.
	 * @param key
	 * @param data
	 * @return plain text or null if error.
	 * @throws InvalidKeyException if secret key is invalid.
	 */
	public static byte[] decrypt(SecretKey key, byte[] data)throws InvalidKeyException{
		
		if(key == null || data == null){
			FxLog.e(TAG, "> decrypt # Input data is null");
			throw new IllegalArgumentException("input is null");
		}
		
		byte[] plainText = null;
		
		try {
			//1 get Cipher
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
			//2 initialize Cipher
			cipher.init(Cipher.DECRYPT_MODE, key, CBC_SALT);
			//3 do decryption
			plainText = cipher.doFinal(data);

		} catch (NoSuchAlgorithmException e) {
			FxLog.e(TAG, String.format("> decrypt # cipher cannot initialize using specific algorithm\n%s", e.getMessage()));
		} catch (NoSuchPaddingException e) {
			FxLog.e(TAG, String.format("> decrypt # cipher cannot initialize using specific padding\n%s", e.getMessage()));
		
		} catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> decrypt # Secret key is invalid\n%s", e.getMessage()));
			throw e;
		} catch (InvalidAlgorithmParameterException e) {
			FxLog.e(TAG, String.format("> decrypt # Initial Vector is invalid\n%s", e.getMessage()));		
		} catch (IllegalBlockSizeException e) {
			FxLog.e(TAG, String.format("> decrypt # Illegal block size\n%s", e.getMessage()));
		} catch (BadPaddingException e) {
			FxLog.e(TAG, String.format("> decrypt # Bad padding\n%s", e.getMessage()));
		}

		return plainText;
	}

}