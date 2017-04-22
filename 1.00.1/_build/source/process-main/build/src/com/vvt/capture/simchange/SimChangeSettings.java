package com.vvt.capture.simchange;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;


public class SimChangeSettings {
	private static final String TAG = "SimChangeSettings";
	private static final String SETTINGS_FOLDER_NAME = "simchange";
	private static final String SETTINGS_FILE_NAME = "simchangesettings.txt";
	private static String m_SimId;

	public static void setSimId(String appPath, String text) {
		m_SimId = text;
		writeFile(getFilename(appPath), text);
	}

	public static String getSimId(String appPath) {

		if(FxStringUtils.isEmptyOrNull(m_SimId)) {
			if(new File(getFilename(appPath)).exists())
				m_SimId = readFile(getFilename(appPath));
			else
				return null;
		}
		
		return m_SimId;
	}

	private static String getFilename(String appPath){
		File file = null;
		String refIdFolder = Path.combine(appPath, SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(refIdFolder, SETTINGS_FILE_NAME));
	}
	
	private static boolean writeFile(String path, String content){
		File savepath = new File(path);	
		BufferedWriter bWriter;
		try {
			bWriter = new BufferedWriter(new FileWriter(savepath, false), 256);
			bWriter.write(content);
			bWriter.flush();
			bWriter.close();
			return true;
		} catch (IOException e) {
			return false; 
		}
	}
	
	private static String readFile(String path) {
		String result = null;
		try {
			String thisLine;
			BufferedReader bReader = new BufferedReader(new FileReader(path), 256);
			while ((thisLine = bReader.readLine()) != null) {
				result = thisLine;
			} 
		} 
		catch (FileNotFoundException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		catch (IOException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		
		return result;
	}
}
