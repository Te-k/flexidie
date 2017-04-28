package com.vvt.util.test;

import com.vvt.logger.FxLog;
import com.vvt.zip.GZIPCompressor;
import com.vvt.zip.GZIPListener;

import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;

public class AsyncGZIPCompressorTest extends AndroidTestCase implements GZIPListener{

private static final String TAG = "AsyncGZIPCompressorTest";
	
	private static final String INPUT_FILE = "/sdcard/file.txt";
	private static final String OUTPUT_FILE = "/sdcard/file.gzip";
	
	public void testAsyncCompress(){
		
		new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.d(TAG, String.format("> testAsyncCompress # Started, Thread ID %d", Thread.currentThread().getId()));
				
				GZIPCompressor compressor = new GZIPCompressor();
				assertEquals(true, compressor.compress(INPUT_FILE, OUTPUT_FILE, AsyncGZIPCompressorTest.this));
				
				//double call test
				assertEquals(false, compressor.compress(INPUT_FILE, OUTPUT_FILE, AsyncGZIPCompressorTest.this));
				Looper.loop();
			}
		}.start();
		
		
		
		//wait for result
		SystemClock.sleep(10000);
	}
	
	public void testAsyncCompressWithNullListener(){
		
		new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.d(TAG, String.format("> testAsyncCompressWithNullListener # Started, Thread ID %d", Thread.currentThread().getId()));
				
				GZIPCompressor compressor = new GZIPCompressor();
				assertEquals(true, compressor.compress(INPUT_FILE, OUTPUT_FILE, null));
				
				//double call test
				assertEquals(false, compressor.compress(INPUT_FILE, OUTPUT_FILE, AsyncGZIPCompressorTest.this));
				Looper.loop();
			}
		}.start();
		
		
		//wait for result
		SystemClock.sleep(10000);
	}

	@Override
	public void onCompressSuccess(String resultPath) {
		FxLog.d(TAG, String.format("> onCompressSuccess # Thread ID %d, result path: %s", Thread.currentThread().getId(), resultPath));
		
	}

	@Override
	public void onCompressError(Exception err) {
		FxLog.e(TAG, String.format("> onCompressError # Thread ID %d\nError message: %s", Thread.currentThread().getId(), err.getMessage() ));
		
	}
}
