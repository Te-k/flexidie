package com.vvt.phoenix.util.test;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.FileUtil;

public class DataBufferTest {
	// Debugging
	private static final String TAG = "DataBufferTest";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	// Constants
	private static final String FILE_INPUT_PATH = "/sdcard/byteArray.dat";
	private static final String FILE_OUTPUT_PATH = "/sdcard/byteArray_out.dat";
	
	public void testToArrayAndToArray(){
		DataBuffer buffer = new DataBuffer();
		try{
			FileInputStream fIn = FileUtil.getFileInputStream(FILE_INPUT_PATH);
			FileOutputStream fOut = FileUtil.getFileOutputStream(FILE_OUTPUT_PATH);
			
			byte[] b = new byte[8];
			int bytes = fIn.read(b);
			while(bytes != -1){
				buffer.writeBytes(bytes, 0, b);
				bytes = fIn.read(b);
			}
			
			fOut.write(buffer.toArray());
			buffer.writeUTF("Dew");
			fOut.write(buffer.toArray());
		}catch(FileNotFoundException fex){
			if(LOCAL_LOGE)Log.e(TAG, "FileNotFoundException: "+fex.getMessage());
			return;
		}catch(IOException ioex){
			if(LOCAL_LOGE)Log.e(TAG, "IOException: "+ioex.getMessage());
			return;
		}
	}
}
