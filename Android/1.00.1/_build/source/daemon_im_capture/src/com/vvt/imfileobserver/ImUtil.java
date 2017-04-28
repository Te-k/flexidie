package com.vvt.imfileobserver;

import java.io.File;

import com.vvt.im.Customization;
import com.vvt.logger.FxLog;


public class ImUtil {
	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "ImUtil";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGW = Customization.WARNING;
	
	public static boolean isHaveFileName(String path, String fileName) {
		if(LOGV) FxLog.v(TAG,"isHaveFileName # ENTER ...");
		
		boolean isHaveFile = false;
		
		File file = new File(path);

		if(file.exists()) {
			String[] listFile = file.list();
			for(int i = 0 ; i< listFile.length ; i++) {
				if(LOGV) FxLog.v(TAG, String.format(
						"listFile[i] : %s, contains : %s", 
						listFile[i] , listFile[i].contains(fileName)));
				
				if (listFile[i].contains(fileName)) {
					isHaveFile = true;
					break;
				}
			}
			if(LOGV) FxLog.v(TAG,"isHaveFileName # isHaveFile : " +isHaveFile);
		} else {
			if(LOGW) FxLog.w(TAG,"isHaveFileName # This device doesn't have /data/app");
		}
		
		if(LOGV) FxLog.v(TAG,"isHaveFileName # EXIT ...");
		return isHaveFile;
	}
}
