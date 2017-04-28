package com.vvt.database;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.os.SystemClock;

import com.fx.daemon.Customization;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public abstract class VtDatabase {
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	public SQLiteDatabase getReadableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READWRITE);
	}
	
	public SQLiteDatabase getWritableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READWRITE);
	}
	
	protected abstract String getDebugTag();
	protected abstract String getFolderName();
	protected abstract String getFilename();
	
	protected abstract void createTables();
	protected abstract void deleteTables();
	
	protected String getDatabasePath() {
		return String.format("%s/%s", getFolderName(), getFilename());
	}
	
	protected SQLiteDatabase openDatabase(int flag) {
		SQLiteDatabase db = null;
		
		String folderName = getFolderName();
		boolean isFolderCreated = FileUtil.isFileExist(folderName);
		
		if (isFolderCreated) {
			db = tryOpenDatabase(flag);
			
			String dbPath = getDatabasePath();
			boolean isDbFileExisted = FileUtil.isFileExist(dbPath);
			
			if (db == null && isDbFileExisted) {
				int attemptLimit = 5;
				while (db == null && attemptLimit > 0) {
					if (LOGV) FxLog.v(getDebugTag(), "Cannot open database. Retrying ...");
					
					SystemClock.sleep(1000);
					db = tryOpenDatabase(flag);
					
					attemptLimit--;
				}
			}
		}
		
		return db;
	}
	
	/**
	 * The parent folder must be created first, otherwise 
	 * the database file won't be created (to avoid StackoverflowException).
	 */
	private SQLiteDatabase tryOpenDatabase(int flag) {
		SQLiteDatabase db = null;
		VtCursorFactory cursorFactory = new VtCursorFactory();
		
		String dbPath = getDatabasePath();
		
		if (FileUtil.isFileExist(dbPath)) {
			try {
				db = SQLiteDatabase.openDatabase(dbPath, cursorFactory, flag);
					if (LOGV) FxLog.v(getDebugTag(), String.format(
							"%s is found", getDatabasePath()));
			} 
			catch (SQLiteException e) {
					if (LOGE) FxLog.e(getDebugTag(), String.format(
							"%s is found, but cannot open.", getDatabasePath()));
			}
		}
		
		// Database files are not created yet
		else {
				if (LOGV) FxLog.v(getDebugTag(), String.format(
						"%s is not created. Creating ..", getDatabasePath()));
			
			// Create new file, if the application path exist without db files
			createTables();
			db = openDatabase(flag);
		}
		
		return db;
	}

}
