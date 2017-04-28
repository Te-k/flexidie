package com.fx.pmond.ref;

import android.net.Uri;

import com.vvt.shell.Shell;

public class MonitorDaemonResource {
	
	public static final String PROCESS_NAME = "pmond";
	
	public static final String DEX_ZIP_FILENAME = String.format("%s.zip", PROCESS_NAME);
	public static final String SECURITY_CONFIG_FILE = "pmond-config.dat";
	
	public static final String EXTRACTING_PATH = "/data/misc/dm";
	static final String[] RESOURCE_FILENAMES = { DEX_ZIP_FILENAME, SECURITY_CONFIG_FILE };
	
	static final String MAIN_CLASS = "com.fx.pmond.MonitorDaemonMain";
	
	static final String NATIVE_LIBS_PATH = "/data/misc/dm";
	static final String[] NATIVE_LIB_FILENAMES = { Shell.LIB_EXEC_FILE };
	
	public static final String LOG_FOLDER = "/data/misc/dm";
	public static final String LOG_FILENAME = "fx.log";
	
	public static final long MONITOR_INTERVAL = 37*1000;
	
	public static final String STARTUP_SCRIPT_PATH = 
			String.format("%s/%s", EXTRACTING_PATH, PROCESS_NAME);
	
	public static final Uri URI_STARTUP_SUCCESS = 
			Uri.parse("content://com.fx.pmond/startup_complete");
	
	public static final String SOCKET_NAME = "com.fx.socket.pmond";
	
}
