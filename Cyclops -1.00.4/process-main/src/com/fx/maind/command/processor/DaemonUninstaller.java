package com.fx.maind.command.processor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.RemoteUninstaller;

public class DaemonUninstaller implements RemoteUninstaller {

	private final static String TAG = "DaemonUninstaller";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private AppEngine mAppEngine;
	
	public DaemonUninstaller(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	@Override
	public void uninstallApplication() {
		if (LOGV) FxLog.v(TAG, "uninstallApplication # ENTER ...");
		
		try {
			
			String packageName = DaemonPackageNameManager.getPackageName(mAppEngine);
			
			if(mAppEngine.getWritablePath() != null) {
				File file = new File(mAppEngine.getWritablePath());
				
				if (file.exists()) {
					if (LOGV) FxLog.v(TAG, "uninstallApplication # Delete files");
					try {
						FileUtil.deleteAllFile(file, new ArrayList<String>());
					} 
					catch (IOException e) { /* ignore */ }
				}
			}
			
			if (LOGV) FxLog.v(TAG, "uninstallApplication # Uninstall package");
			
			ServiceManager.getInstance().uninstallAll(packageName);
		}
		catch (Throwable t) {
			if (LOGE) FxLog.e(TAG, t.toString());
		}

		if (LOGV) FxLog.v(TAG, "uninstallApplication # EXIT ...");
	}

}
