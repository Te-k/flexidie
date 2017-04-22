package com.vvt.database;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.os.SystemClock;

import com.vvt.daemon.util.Customization;
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
	protected abstract String getDatabasePath();
	
	protected abstract void createTables();
	protected abstract void deleteTables();
	
	protected SQLiteDatabase openDatabase(int flag) {
		SQLiteDatabase db = tryOpenDatabase(flag);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if (LOGV) FxLog.v(getDebugTag(), "Cannot open database. Retrying ...");
			
			SystemClock.sleep(1000);
			db = tryOpenDatabase(flag);
			
			attemptLimit--;
		}
		
		return db;
	}
	
	private SQLiteDatabase tryOpenDatabase(int flag) {
		SQLiteDatabase db = null;
		VtCursorFactory cursorFactory = new VtCursorFactory();
		
		// Try open db from system path
		String path = getDatabasePath();
		
		if (FileUtil.isFileExist(path)) {
			try {
				db = SQLiteDatabase.openDatabase(path, cursorFactory, flag);
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
