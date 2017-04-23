package com.fx.maind.command.processor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class RemoteUninstallProcessor {
	
	private final static String TAG = "UninstallCommandProcess";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private AppEngine mAppEngine;
	
	public RemoteUninstallProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}

	public void process() {
		if (LOGV) FxLog.v(TAG, "process # ENTER ...");
		
		try {
			if(mAppEngine.getWritablePath() != null) {
				File file = new File(mAppEngine.getWritablePath());
				if (file.exists()) {
					if (LOGV) FxLog.v(TAG, "process # Delete files");
					try {
						FileUtil.deleteAllFile(file, new ArrayList<String>());
					} 
					catch (IOException e) { /* ignore */ }
				}
			}
			
			if (LOGV) FxLog.v(TAG, "process # Uninstall package");
			String packageName = DaemonPackageNameManager.getPackageName(mAppEngine);
			ServiceManager.getInstance().uninstallAll(packageName);
		}
		catch (Throwable t) {
			if (LOGE) FxLog.e(TAG, t.toString());
		}

		if (LOGV) FxLog.v(TAG, "process # EXIT ...");
	}

}
