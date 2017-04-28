package com.vvt.util.test;

import java.io.File;

import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;

import com.vvt.crc.CRC32Checksum;
import com.vvt.crc.CRC32Listener;
import com.vvt.logger.FxLog;

public class AsyncCrc32Test extends AndroidTestCase implements CRC32Listener{
	
	//Debugging
	private static final String TAG = "AsyncCrc32Test";
		
	//constant
	private static final String FILE_PATH = "/sdcard/file.txt";
	private static final String FILE_CRC32_VALUE = "ef07e2c3";
	private static final String FILE_PART_CRC32_VALUE = "20813195";
	
	//Members
	private static long mExpectedCrc;
	
	
	public void testAsyncCrc32WholeFile(){
		
		
		
		new Thread(){
			@Override
			public void run(){
				FxLog.v(TAG, String.format("Worker Thread > testAsyncCrc32WholeFile # Thread ID %d", Thread.currentThread().getId()));
				Looper.prepare();
				//prepare expected CRC value
				mExpectedCrc = Long.parseLong(FILE_CRC32_VALUE, 16);
				
				//calculate
				CRC32Checksum crc = new CRC32Checksum();
				crc.calculate(FILE_PATH, AsyncCrc32Test.this);
				
				//test double request
				crc.calculate(FILE_PATH, AsyncCrc32Test.this);
				Looper.loop();
			}
		}.start();
		
		
		
		
		SystemClock.sleep(10000);
	}
	
	/*public void testAsyncCrc32FilePart(){
		
		new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.v(TAG, String.format("Worker Thread > testAsyncCrc32WholeFile # Thread ID %d", Thread.currentThread().getId()));
				//prepare expected CRC value
				mExpectedCrc = Long.parseLong(FILE_PART_CRC32_VALUE, 16);
				
				//calculate
				CRC32Checksum crc = new CRC32Checksum();
				File f = new File(FILE_PATH);
				long fLen = f.length();
				
				crc.calculate(FILE_PATH, 8, (int) (fLen - 8), AsyncCrc32Test.this);
				
				
				 //Snippet for test parameter validation
				 
				//crc.calculate(FILE_PATH, 8, 0, this);									// count = 0
				//crc.calculate(FILE_PATH, -1, (int) (fLen - 8), this);					// offset < 0
				//crc.calculate(FILE_PATH, (int) fLen+1, (int) (fLen - 8), this);		// offset > file length
				//crc.calculate(FILE_PATH, 8, (int) (fLen - 5), this);					// offset + count > file length
				
						
				//test double request
				crc.calculate(FILE_PATH, AsyncCrc32Test.this);
				Looper.loop();
			}
		}.start();
		
		
		SystemClock.sleep(10000);
	}*/

	@Override
	public void onCalculateCRC32Success(long result) {
		FxLog.d(TAG, String.format("> onCalculateCRC32Success # Thread ID = %d", Thread.currentThread().getId()));
		FxLog.d(TAG, String.format("> onCalculateCRC32Success # Result = %d", result));
		FxLog.v(TAG, String.format("> onCalculateCRC32Success # Expected Result = %d", mExpectedCrc));
		
		assertEquals(mExpectedCrc, result);
		
	}

	@Override
	public void onCalculateCRC32Error(Exception err) {
		FxLog.e(TAG, String.format("> onCalculateCRC32Error # Thread ID = %d", Thread.currentThread().getId()));
		FxLog.e(TAG, String.format("> onCalculateCRC32Error # %s", err.getMessage()));
		
	}

	

}
