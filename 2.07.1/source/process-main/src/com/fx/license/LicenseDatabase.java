package com.fx.license;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.fx.maind.ref.MainDaemonResource;
import com.vvt.database.VtDatabase;
import com.vvt.logger.FxLog;

class LicenseDatabase extends VtDatabase {
	
	private static final String TAG = "LicenseDatabase";
	private static final String DATABASE_NAME = LicenseDatabaseMetadata.DB_NAME;
    private static LicenseDatabase sInstance;
    
    public static LicenseDatabase getInstance() {
    	if (sInstance == null) {
    		sInstance = new LicenseDatabase();
    	}
    	return sInstance;
    }
    
    private LicenseDatabase() { }
    
    protected void createTables() {
    	String systemPath = getDatabasePath();
		SQLiteDatabase db = null;
		
		try {
			db = SQLiteDatabase.openOrCreateDatabase(systemPath, null);
			createLicenseTable(db);
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
		db.execSQL(String.format("DROP TABLE IF EXISTS %1$s", LicenseDatabaseMetadata.License.TABLE_NAME));
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

    private void createLicenseTable(SQLiteDatabase db) {
		String sql = String.format("CREATE TABLE %1$s " +
				"(%2$s INTEGER, " +
				"%3$s TEXT, " +
				"%4$s TEXT, " +
				"%5$s INTEGER);"
				, LicenseDatabaseMetadata.License.TABLE_NAME // 1
				, LicenseDatabaseMetadata.License.ACTIVATION_STATUS // 2
				, LicenseDatabaseMetadata.License.ACTIVATION_CODE // 3
				, LicenseDatabaseMetadata.License.SERVER_HASH // 4
				, LicenseDatabaseMetadata.License.CONFIGURATION_ID // 5
				);
		db.execSQL(sql);
	}
}
