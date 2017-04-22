package com.vvt.util.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import com.vvt.crc.CRC32Checksum;
import com.vvt.logger.FxLog;

import android.test.AndroidTestCase;

/**
 * @author tanakharn
 *
 * To run this test case
 * you have to add input file into SDCard and specify path to this file at FILE_PATH
 * and add its true CRC value at FILE_CRC32_VALUE for compare with runtime CRC value
 */
public class Crc32Test extends AndroidTestCase{
	
	//Debugging
	private static final String TAG = "Crc32Test";
	
	//constant
	private static final String FILE_PATH = "/sdcard/file.txt";
	private static final String FILE_CRC32_VALUE = "ef07e2c3";
	
	public void testCrc32(){
		
		//prepare expected result
		long expectedCrc = Long.parseLong(FILE_CRC32_VALUE, 16);
		
		//read file
		File f = new File(FILE_PATH);
		byte[] buffer = new byte[(int) f.length()];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.read(buffer);
			fIn.close();
		}catch(IOException e){
			FxLog.e(TAG, String.format("> testCrc32 # Exception while reading input file\n%s", e.getMessage()));
			return;
		}
		
		//calculate
		long crc = CRC32Checksum.calculate(buffer);
		
		assertEquals(expectedCrc, crc);
	}

}
