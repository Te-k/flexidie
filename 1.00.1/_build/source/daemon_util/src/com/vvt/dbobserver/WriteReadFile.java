package com.vvt.dbobserver;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.vvt.daemon.util.Customization;
import com.vvt.logger.FxLog;

public class WriteReadFile {
	
	private static final String TAG = "WriteReadFile";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	public static void writeFile(String path, String content){
		if (LOGV) FxLog.v(TAG, "writeFile # ENTER ...");
		File savepath = new File(path);	
		BufferedWriter bWriter;
		try {
			bWriter = new BufferedWriter(new FileWriter(savepath, false), 256);
			bWriter.write(content);
			bWriter.flush();
			bWriter.close();
		} catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("writeFile # error: %s", e.getMessage()));
		}
		if (LOGV) FxLog.v(TAG, "writeFile # EXIT ...");
	}
	
	public static String readFile(String path) {
		if (LOGV) FxLog.v(TAG, "readFile # ENTER ...");
		String result = "-1";
		BufferedReader bReader = null;
		try {
			String thisLine;
			bReader = new BufferedReader(new FileReader(path), 256);
			while ((thisLine = bReader.readLine()) != null) {
				result = thisLine;
			} 
			
			if(bReader != null) {
				bReader.close();
			}
		} 
		catch (FileNotFoundException e) {
			if (LOGV) FxLog.v(TAG, "FileNotFoundException, We will return default value(-1).");
			if (LOGV) FxLog.v(TAG, "FileNotFoundException, This case will occur only in first time.");
		}
		catch (IOException e) {
			if (LOGV) FxLog.v(TAG, "IOException, Can't read this file : " + path);
			if (LOGV) FxLog.v(TAG, "IOException, We will return default value(-1).");
		} 
		
		if (LOGV) FxLog.v(TAG, "readFile # EXIT ...");
		return result;
		
	}
	
}
