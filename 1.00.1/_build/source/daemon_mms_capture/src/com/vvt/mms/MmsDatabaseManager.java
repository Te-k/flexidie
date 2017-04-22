package com.vvt.mms;


import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.logger.FxLog;

public class MmsDatabaseManager {
	
	private static final String TAG = "MmsDatabaseManager";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	public static long getLatestMmsId() {
		if(LOGV) FxLog.v(TAG, "getLatestMmsId # ENTER ...");
		
		SQLiteDatabase db = MmsDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGW) FxLog.w(TAG, "getLatestMmsId # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return -1;
		}
		
		Cursor cursor = null;
		long id = -1;
		try {
			String sql = String.format("SELECT MAX(%s) FROM %s", 
					MmsDatabaseHelper.COLUMN_ID, MmsDatabaseHelper.TABLE_PDU);
			
			cursor = db.rawQuery(sql, null);
			
			if (cursor == null || cursor.getCount() == 0) {
				if(LOGW) FxLog.w(TAG, "getLatestMmsId # Query database FAILED!! -> EXIT ...");
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
			if(LOGE) FxLog.e(TAG, String.format("getLatestMmsId # error: %s", e.toString()));
		} finally {
			if (cursor != null)
				cursor.close();
			if(db != null)
				db.close();
		}
		
		if(LOGV) FxLog.v(TAG, String.format("getLatestMmsId # id: %d", id));
		if(LOGV) FxLog.v(TAG, "getLatestMmsId # EXIT ...");
		return id;
	}
	
}
