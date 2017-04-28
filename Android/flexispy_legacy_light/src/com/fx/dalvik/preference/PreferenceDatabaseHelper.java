package com.fx.dalvik.preference;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

class PreferenceDatabaseHelper extends SQLiteOpenHelper {
	
	private static final String DATABASE_NAME = PreferenceDatabaseMetadata.DB_NAME;
	private static final int DATABASE_VERSION = 2;

	private static PreferenceDatabaseHelper sInstance;
	
	static synchronized PreferenceDatabaseHelper getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new PreferenceDatabaseHelper(context);
		}
		return sInstance;
	}
	
	private PreferenceDatabaseHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		createConnectionHistoryTable(db);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", 
				PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME));
		db.close();
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
				"%12$s INTEGER);"
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
				);
		
		db.execSQL(sql);
	}
}
