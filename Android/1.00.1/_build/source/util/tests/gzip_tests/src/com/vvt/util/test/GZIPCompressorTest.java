package com.vvt.util.test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.zip.GZIPInputStream;

import android.os.SystemClock;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.zip.GZIPCompressor;

public class GZIPCompressorTest extends AndroidTestCase{
	
	private static final String TAG = "GZIPCompressorTest";
	
	private static final String INPUT_FILE = "/sdcard/file.txt";
	
	public void testCompress(){
			
		//1 prepare input file
		File fIn = new File(INPUT_FILE);
		long fInLen = fIn.length();
		Log.d(TAG, String.format("> testCompress # Input length = %d", fInLen));
		
		//2 read entire image into byte array 
		FileInputStream fInStream;
		byte[] imgData = null;
		try{
			fInStream = new FileInputStream(fIn);
			imgData = new byte[(int) fInLen];
			fInStream.read(imgData);
			fInStream.close();
		}catch(IOException e){
			Log.e(TAG, String.format("> testCompress # Exception while reading input image: %s", e.getMessage()));
			return;
		}
		
		//3 compress it !
		byte[] compressedImgData = null;
		try {
			compressedImgData = GZIPCompressor.compress(imgData);
			if(compressedImgData != null){
				Log.i(TAG, String.format("> testCompress # Compress success, result length = %d", compressedImgData.length));
			}else{
				Log.w(TAG, "> testCompress # Compressor return null");
				return;
			}
		} catch (IOException e) {
			Log.e(TAG, String.format("> testCompress # Exception while compressing: %s", e.getMessage()));
		}
		
		
		//4 decompressed it
		ByteArrayInputStream is = new ByteArrayInputStream(compressedImgData);
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		byte[] buf = new byte[8];
		try {
			GZIPInputStream gZip = new GZIPInputStream(is);
			int readCount = gZip.read(buf);
			while(readCount > 0){
				os.write(buf, 0, readCount);
				readCount = gZip.read(buf);
			}
		} catch (IOException e) {
			Log.e(TAG, String.format("> testCompress # Exception while decompressing: %s", e.getMessage()));
			return;
		}
		
		//5 compare decompressed data with original data
		byte[] decompressed = os.toByteArray();
		assertEquals(true, Arrays.equals(imgData, decompressed));
		
		
		//SystemClock.sleep(10000);
	}

}
