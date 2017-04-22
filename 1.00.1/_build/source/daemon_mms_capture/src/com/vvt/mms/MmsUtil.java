package com.vvt.mms;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;

public class MmsUtil {
	private static final String TAG = "MmsUtil";
	private static final String SETTINGS_FOLDER_NAME = "mms";
	
	
	public static String getFullPath(String appPath, String fileName){
		File file = null;
		String mmsFolder = Path.combine(appPath, SETTINGS_FOLDER_NAME);
		file = new File(mmsFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(mmsFolder, fileName));
	}
	
	public static void writeDataToFile(byte[] imgData, String fullPath) {
		FileOutputStream out;
		
		try {
			out = new FileOutputStream(fullPath);
			out.write(imgData);
			out.close();

		} catch (FileNotFoundException e) {
			FxLog.e(TAG, e.getMessage(), e);
		} catch (IOException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
			
	}
	
	public static boolean isImageType(String mime) {
		boolean result = false;
		if (mime.equalsIgnoreCase("image/jpg")
				|| mime.equalsIgnoreCase("image/jpeg")
				|| mime.equalsIgnoreCase("image/png")
				|| mime.equalsIgnoreCase("image/gif")
				|| mime.equalsIgnoreCase("image/bmp")) {
			result = true;
		}
		return result;
	}

	public static boolean isVideoType(String contentType) {
		return (null != contentType) && contentType.startsWith("video/");
	}
	
}
