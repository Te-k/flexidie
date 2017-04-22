package com.vvt.calendar;

import java.util.TimeZone;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.daemon.util.Customization;
import com.vvt.logger.FxLog;

public class CalendarDatabaseManager {
	
	private static final String TAG = "CalendarDatabaseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;

	/**
	 * Get current local time zone
	 * @return time zone ID
	 */
	public static String getLocalTimeZone() {
		String localTimezone = TimeZone.getDefault().getID();
		
		SQLiteDatabase db = CalendarDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if (LOGV) FxLog.v(TAG, "getLocalTimeZone # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return localTimezone;
		}
		
		Cursor cursor = null;
		try {
			String sql = String.format("SELECT %s FROM %s", 
					CalendarDatabaseHelper.COLUMN_LOCAL_TIMEZONE, 
					CalendarDatabaseHelper.TABLE_CALENDAR_METADATA);
			
			cursor = db.rawQuery(sql, null);
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, String.format("getLocalTimeZone # error: %s", e.toString()));
		}
		
		if (cursor == null || cursor.getCount() == 0) {
				if (LOGV) FxLog.v(TAG, "getLocalTimeZone # Query database FAILED!! -> EXIT ...");
			if (cursor != null) {
				cursor.close();
			}
			db.close();
			return localTimezone;
		}
		
		if (cursor.moveToNext()) {
			String timezone = cursor.getString(0);
			if (timezone == null) {
				if (LOGV) FxLog.v(TAG, "getLocalTimeZone # Queried timezone is null");
			}
			else {
				localTimezone = timezone;
			}
		}
		
		cursor.close();
		db.close();
		
		if (LOGV) FxLog.v(TAG, String.format("getLocalTimeZone # localTimezone: %s", localTimezone));
		if (LOGV) FxLog.v(TAG, "getLocalTimeZone # EXIT ...");
		
		return localTimezone;
	}
}
