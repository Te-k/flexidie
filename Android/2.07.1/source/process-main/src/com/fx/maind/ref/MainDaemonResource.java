package com.fx.maind.ref;

import android.net.Uri;

public class MainDaemonResource {

	public static final String PACKAGE_NAME = "com.fx.maind";
	
	public static final String PROCESS_NAME = "maind";
	
	public static final String DEX_ZIP_FILENAME = String.format("%s.zip", PROCESS_NAME);
	public static final String SECURITY_CONFIG_FILE = "maind-config.dat";
	
	static final String MAIN_CLASS = "com.fx.maind.MainDaemonMain";
	
	public static final String EXTRACTING_PATH = "/data/misc/dm";
	public static final String NATIVE_LIBS_PATH = "/data/misc/dm";
	
	public static final String LOG_FOLDER = "/data/misc/dm";
	public static final String LOG_FILENAME = "fx.log";
	
	public static final String PERSISTED_DEVICE_ID_PATH = 
			String.format("%s/%s", EXTRACTING_PATH, "dev_id");
	
	public static final long MONITOR_INTERVAL = 47*1000;
	
	public static final String STARTUP_SCRIPT_PATH = 
			String.format("%s/%s", EXTRACTING_PATH, PROCESS_NAME);
	
	public static final Uri URI_STARTUP_SUCCESS = 
			Uri.parse("content://com.fx.maind/startup_success");
	
	public static final String SOCKET_NAME = "com.fx.socket.maind";
	
}
