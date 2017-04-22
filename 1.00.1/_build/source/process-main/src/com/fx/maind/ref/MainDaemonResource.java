package com.fx.maind.ref;

import android.net.Uri;

import com.vvt.shell.Shell;

public class MainDaemonResource {
	public static final String PACKAGE_NAME = "com.fx.maind";
	public static final String PROCESS_NAME = "maind";
	public static final String PRODUCT_DEFINITION_FILENAME = "ProductDefinition";
	
	static final String DEX_ZIP_FILENAME = String.format("%s.zip", PROCESS_NAME);
	static final String MAIN_CLASS = "com.fx.maind.MainDaemonMain";
	
	public static final String EXTRACTING_PATH = "/data/misc/dm";
	static final String[] RESOURCE_FILENAMES = { DEX_ZIP_FILENAME };
	
	static final String NATIVE_LIBS_PATH = "/data/misc/dm";
	static final String[] NATIVE_LIB_FILENAMES = { Shell.LIB_EXEC_FILE };
	
	public static final String LOG_FOLDER = "/data/misc/dm";
	public static final String LOG_FILENAME = "fx.log";
	
	public static final long MONITOR_INTERVAL = 47*1000;
	
	public static final String STARTUP_SCRIPT_PATH = 
			String.format("%s/%s", EXTRACTING_PATH, PROCESS_NAME);
	
	public static final Uri URI_STARTUP_SUCCESS = 
			Uri.parse("content://com.fx.maind/startup_success");
	
	public static final String SOCKET_NAME = "com.fx.socket.maind";
	
}
