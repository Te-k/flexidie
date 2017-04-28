package com.vvt.util.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import javax.crypto.SecretKey;

import junit.framework.Assert;
import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;

import com.vvt.crc.CRC32Checksum;
import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESDecryptListener;
import com.vvt.crypto.AESEncryptListener;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.logger.FxLog;

public class AsyncAesCipherTest extends AndroidTestCase implements AESEncryptListener, AESDecryptListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "AsyncAesCipherTest";
	
	/*
	 * Constants
	 */
	private static final String INPUT_FILE_PATH = "/sdcard/file.txt";
	private static final String ENCRYPTED_FILE_PATH = "/sdcard/file.cipher";
	private static final String DECRYPTED_FILE_PATH = "/sdcard/file.plain";
	
	/*
	 * Test cases selector
	 */
	private static final boolean TEST_ENCRYPT_WITH_ILLEGAL_ARGUMENTS = false;
	private static final boolean TEST_DECRYPT_WITH_ILLEGAL_ARGUMENTS = false;
	private static final boolean TEST_ENCRYPT_DECRYPT = true;
	
	/*
	 * Member
	 */
	private SecretKey mKey;
	private AESCipher mCipher;
	private long mInputChecksum;
	
	@Override
	protected void setUp() {
		FxLog.d(TAG, "!setUp");
		mKey = AESKeyGenerator.generate();
		
		mCipher = new AESCipher();
	}
	
	public void testCases(){
		if(TEST_ENCRYPT_WITH_ILLEGAL_ARGUMENTS){
			_testEncryptWithIllegalArgument();
		}
		if(TEST_DECRYPT_WITH_ILLEGAL_ARGUMENTS){
			_testDecryptWithIllegalArgument();
		}
		if(TEST_ENCRYPT_DECRYPT){
			_testEncryptDecrypt();
		}
		
		// hold tester thread for results
		SystemClock.sleep(10000);
	}
	
	public void _testEncryptWithIllegalArgument(){
				
		//1 test supply null
		try{
			//mCipher.encrypt(null, "", "", null);
			//mCipher.encrypt(mKey , null, "", null);
			mCipher.encrypt(mKey , "", null, null);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			
		}
		
		//2 test supply invalid file path and see result in onAESEncryptError()
		mCipher.encrypt(mKey , "", "", this);

	}
	
	public void _testDecryptWithIllegalArgument(){
				
		
		//1 test supply null
		try{
			mCipher.decrypt(null, "", "", null);
			//mCipher.decrypt(mKey, null, "", null);
			//mCipher.decrypt(mKey , "", null, null);
			Assert.fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			
		}
		
		//2 test supply invalid file path and see result in onAESDecryptError()
		mCipher.decrypt(mKey , "", "", this);
	}
	
	
	public void _testEncryptDecrypt(){
		FxLog.d(TAG, String.format("> _testEncryptDecrypt # Thread ID: %d", Thread.currentThread().getId()));
				
		/*
		 * request for encryption from worker thread
		 */
		new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				
				FxLog.v(TAG, String.format("> _testEncryptDecrypt > run # Thread ID: %d", Thread.currentThread().getId()));
				
				// calculate checksum value of input file
				File f = new File(INPUT_FILE_PATH);
				byte[] buffer = new byte[(int) f.length()];
				try{
					FileInputStream fIn = new FileInputStream(f);
					fIn.read(buffer);
					fIn.close();
				}catch(IOException e){
					FxLog.e(TAG, 
							String.format("> _testEncryptDecrypt # Thread ID: %d\nError while calculating input file checksum: %s", 
									Thread.currentThread().getId(), e.getMessage()));
					Assert.fail("Exception while calculate input file CRC32 value");
					return;
				}
				mInputChecksum = CRC32Checksum.calculate(buffer);
				
				// request for encryption
				assertEquals(true, mCipher.encrypt(mKey, INPUT_FILE_PATH, ENCRYPTED_FILE_PATH, AsyncAesCipherTest.this));
				//mCipher.encryptASynchronous(mKey, INPUT_FILE_PATH, ENCRYPTED_FILE_PATH, this);
				
				// test double request
				assertEquals(false, mCipher.encrypt(mKey, INPUT_FILE_PATH, ENCRYPTED_FILE_PATH, null));
				
				Looper.loop();
			}
		}.start();
				
	}

	@Override
	public void onAESEncryptSuccess(String resultPath) {
		FxLog.d(TAG, String.format("> onAESEncryptSuccess # Thread ID: %d, Path: %s", Thread.currentThread().getId(), resultPath));
		
		//request for decryption
		assertEquals(true, mCipher.decrypt(mKey, ENCRYPTED_FILE_PATH, DECRYPTED_FILE_PATH, this));
				
		//test double request
		assertEquals(false, mCipher.decrypt(mKey, ENCRYPTED_FILE_PATH, DECRYPTED_FILE_PATH, null));
	}

	@Override
	public void onAESEncryptError(Exception err) {
		FxLog.e(TAG, String.format("> onAESEncryptError # Thread ID: %d, Error Message: %s", Thread.currentThread().getId(), err.getMessage()));
		
		/*
		 * check for testEncryptWithIllegalArgument()
		 * supply invalid file path to AESCipher and it should throw IOException
		 */
		assertEquals(true, (err instanceof IOException));
		
	}

	@Override
	public void onAESDecryptSuccess(String resultPath) {
		FxLog.d(TAG, String.format("> onAESDecryptSuccess # Thread ID: %d, Path: %s", Thread.currentThread().getId(), resultPath));
		

		// calculate checksum value of output file
		File f = new File(resultPath);
		byte[] buffer = new byte[(int) f.length()];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.read(buffer);
			fIn.close();
		}catch(IOException e){
			FxLog.e(TAG, 
					String.format("> onAESDecryptSuccess # Thread ID: %d\nError while calculating output file checksum: %s", 
							Thread.currentThread().getId(), e.getMessage()));
			Assert.fail("Exception while calculate output file CRC32 value");
			return;
		}
		long outputCrc = CRC32Checksum.calculate(buffer);
		
		//compare checksum of input file and decrypted file
		FxLog.i(TAG, String.format("> onAESDecryptSuccess # Input CRC: %d, Output CRC: %d", mInputChecksum, outputCrc));
		assertEquals(mInputChecksum, outputCrc);
	}

	@Override
	public void onAESDecryptError(Exception err) {
		FxLog.e(TAG, String.format("> onAESDecryptError # Thread ID: %d, Error Message: %s", Thread.currentThread().getId(), err.getMessage()));
		
		/*
		 * check for _testDecryptWithIllegalArgument()
		 * supply invalid file path to AESCipher and it should throw IOException
		 */
		assertEquals(true, (err instanceof IOException));
		
	}

}
