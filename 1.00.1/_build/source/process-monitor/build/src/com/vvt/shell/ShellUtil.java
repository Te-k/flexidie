package com.vvt.shell;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;
import java.util.HashSet;

import android.content.Context;
import android.util.Log;

import com.vvt.shell.CannotGetRootShellException.Reason;

public class ShellUtil {
	
	private static final String TAG = "ShellUtil";
	private static boolean LOGV = Customization.SHELL_DEBUG;
	
	public static boolean isProcessRunning(String processName) {
		if (LOGV) Log.v(TAG, "isProcessRunning # ENTER ...");
		
		String processesList = getProcessesList();
		BufferedReader reader = new BufferedReader(new StringReader(processesList), 256);
		
		try {
			String line = null;
			while ((line = reader.readLine()) != null) {
				if (line.contains(processName)) {
					if (LOGV) Log.v(TAG, String.format(
							"isProcessRunning # Process '%s' is running.", processName));
					return true;
				}
			}
		}
		catch (IOException e) {
			if (LOGV) Log.e(TAG, e.getMessage(), e);
		}
		
		if (LOGV) Log.v(TAG, String.format(
				"isProcessRunning # Process '%s' is not running.", processName));
		
		return false;
	}
	
	public static boolean isFileExisted(String path) {
		boolean isFileExisted = false;
		
		try {
			Shell sh = Shell.getRootShell();
			String result = sh.exec(String.format("%s %s", Shell.CMD_LS, path));
			sh.terminate();
			isFileExisted = !result.contains(Shell.NO_SUCH_FILE);
		}
		catch (CannotGetRootShellException e) { 
			isFileExisted = new File(path).exists();
		}
		
		return isFileExisted;
	}

	public static boolean killProcessByName(String processName) {
		boolean foundProcess = false;
		
		if (processName != null) {
			HashSet<LinuxProcess> processes = findDuplicatedProcess(processName);
			
			if (processes.size() > 0) {
				foundProcess = true;
				for (LinuxProcess process : processes) {
					ShellUtil.killProcessByPid(process.pid);
				}
			}
		}
		return foundProcess;
	}
	
	public static void killProcessByPid(String pid) {
		try {
			Shell rootShell = Shell.getRootShell();
			rootShell.exec(String.format("kill -9 %s", pid));
			rootShell.terminate();
		} 
		catch (CannotGetRootShellException e) {
			if (LOGV) Log.e(TAG, String.format(
					"killProcessByPid # Error!! %s", e.toString()));
		}
	}
	
	public static void killSelf() {
		android.os.Process.killProcess(android.os.Process.myPid());
		
		Shell shell = Shell.getShell();
		shell.exec(String.format("kill -9 %d", android.os.Process.myPid()));
		shell.terminate();
	}
	
	public static void remountFileSystem(boolean write) {
		String remountCommand = null;
		Shell shell = null;
		try {
	    	shell = Shell.getRootShell();
	    	String mount = shell.exec(Shell.CMD_MOUNT);
	    	
	    	if (mount != null) {
	    		BufferedReader reader = new BufferedReader(new StringReader(mount), 256);
	    		String line = null;
	    		
	    		// Find /system line
	    		while ((line = reader.readLine()) != null) {
	    			if (line.contains(" /system")) break;
	    		}
	    		
	    		// Check file system info
	    		if (line != null) {
	    			String[] params = line.split(" ");
	    			if (params != null && params.length > 2) {
	    				remountCommand = String.format(
	    						"%s -o %s,remount -t %s %s %s", Shell.CMD_MOUNT, 
	    						write ? "rw" : "ro", params[2], params[0], params[1]);
	    			}
	    		}
	    	}
	    	
	    	if (LOGV) Log.v(TAG, String.format(
	    			"remountFileSystem # remount command: %s", remountCommand));
	    	
	    	if (remountCommand != null) {
	    		shell.exec(remountCommand);
	    	}
	    }
	    catch (CannotGetRootShellException e) {
	    	if (LOGV) Log.e(TAG, String.format("remountFileSystem # Error!! %s", e.toString()));
	    }
	    catch (IOException ioe) {
	    	/* ignore */
	    }
		finally {
			if (shell != null) shell.terminate();
		}
	}

	public static String getProcessesList() {
    	Shell shell = Shell.getShell();
    	String ps = shell.exec(Shell.CMD_PS);
    	shell.terminate();
    	return ps;
	}
	
	/**
	 * Look for all process ID that share the same process name (duplicated).
	 * @param processesList Result from executing 'ps'.
	 * @param processName Specific process name.
	 * @return Collection of duplicated process PID
	 */
	public static HashSet<LinuxProcess> findDuplicatedProcess(String processName) {
		String processesList = getProcessesList();
		
		BufferedReader reader = 
			new BufferedReader(new StringReader(processesList), 256);
		
		HashSet<LinuxProcess> processes = new HashSet<LinuxProcess>();
		
		try {
			LinuxProcess info = null;
			String line = null;
			while ((line = reader.readLine()) != null) {
				if (line.contains(processName)) {
					String[] tokens = line.split("\\s+");
					if (tokens.length > 8) {
						info = new LinuxProcess();
						info.user = tokens[0];
						info.pid = tokens[1];
						info.ppid = tokens[2];
						info.vsize = tokens[3];
						info.rss = tokens[4];
						info.wchan = tokens[5];
						info.pc = tokens[6];
						info.status = tokens[7];
						info.name = tokens[8];
						
						if (info.name.equals(processName) && 
								info.status.equals("S")) {
							processes.add(info);
						}
					}
				}
			}
		}
		catch (IOException e) {
			if (LOGV) Log.e(TAG, "findDuplicatedProcess # Error!!", e);
		}
		return processes;
	}
	
	/**
	 * In OS 4.0, this method must be invoked from the root process.
	 * @param pkgName
	 */
	public static void uninstallApk(String pkgName) {
		if (LOGV) Log.v(TAG, "uninstallApk # ENTER ...");
		
		try {
			Shell shell;
			shell = Shell.getRootShell();
			shell.exec(String.format("pm uninstall %s", pkgName));
			shell.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGV) Log.v(TAG, "uninstallApk # Getting root failed!!");
		}
		
		if (LOGV) Log.v(TAG, "uninstallApk # EXIT ...");
	}
	
	public static boolean isDevicePerfectlyRooted(Context context) throws CannotGetRootShellException {
		String systemFileContent = "Hello Android!!";
		String systemFilePath = "/system/bin/sample.txt";
		
		Shell shell = null;
		try {
			shell = Shell.getRootShell();
		}
		catch (CannotGetRootShellException e) { /* ignore */ }
			
		// Root shell not found
		if (shell == null) {
			throw new CannotGetRootShellException(Reason.SU_EXEC_FAILED);
		}
		
		ShellUtil.remountFileSystem(true);
		
		shell.exec(String.format("echo \"%s\" > %s", systemFileContent, systemFilePath));
		String writtenContent = shell.exec(String.format("cat %s", systemFilePath));
		
		shell.exec(String.format("rm %s", systemFilePath));
		shell.terminate();
		
		ShellUtil.remountFileSystem(false);
		
		// Root perfectly acquired
		if (writtenContent != null && writtenContent.contains(systemFileContent)) {
			return true;
		}
		// Root cannot write to system
		else {
			throw new CannotGetRootShellException(Reason.SYSTEM_WRITE_FAILED);
		}
	}
	
	public static void writeToFile(String path, String msg, boolean append) {
		File logFile = createFile(path);
		
		if (logFile == null || !logFile.canWrite()) {
			if (LOGV) Log.e(TAG, String.format(
					"writeToFile # Cannot write to a specific path: %s", path));
			return;
		}
		
		try {
			BufferedReader reader = new BufferedReader(new StringReader(msg), 256);
			BufferedWriter writer = new BufferedWriter(new FileWriter(logFile, append), 256);
			
			String line = null;
			while ((line = reader.readLine()) != null) {
				writer.append(line);
				writer.append("\r\n");
			}
			writer.flush();
			writer.close();
		}
		catch (IOException e) { /* ignore */ }
	}
	
	private static File createFile(String path) {
		String dirPath = getDirectoryPath(path);
		File dir = new File(dirPath);
		if (! dir.exists()) {
			if (dir.mkdirs()) {
				if (LOGV) Log.v(TAG, String.format(
						"createFile # Directory is created: %s", dirPath));
				
				Shell shell = Shell.getShell();
				shell.exec(String.format("chmod 777 %s", dirPath));
				shell.terminate();
			}
			else {
				if (LOGV) Log.v(TAG, String.format(
						"createFile # Create directory failed: %s", dirPath));
			}
		}
		
		File f = new File(path);
		
		if (! f.exists()) {
			try { 
				if (f.createNewFile()) {
					if (LOGV) Log.v(TAG, String.format(
							"createFile # File is created: %s", path));
					
					Shell shell = Shell.getShell();
					shell.exec(String.format("chmod 666 %s", path));
					shell.terminate();
				}
				
			}
			catch (IOException e) { /* ignore */ }
		}
		
		return f;
	}
	
	private static String getDirectoryPath(String path) {
		String[] folders = path.split("/");
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < folders.length - 1; i++) {
			builder.append(folders[i]).append("/");
		}
		builder.replace(builder.length()-1, builder.length(), "");
		return builder.toString();
	}
	
}
