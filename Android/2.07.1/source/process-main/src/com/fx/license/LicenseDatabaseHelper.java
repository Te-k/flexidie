package com.fx.license;

import java.util.HashMap;

import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;

import com.fx.maind.ref.Customization;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;

class LicenseDatabaseHelper {

	private static final String TAG = "LicenseDatabaseHelper";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;

	private static final int LICENSE = 1;
	
    private static LicenseDatabaseHelper sInstance;
    
    private UriMatcher sUriMatcher;
	private LicenseDatabase mLicenseDatabase;
    
    public static LicenseDatabaseHelper getInstance() {
    	if (sInstance == null) {
    		sInstance = new LicenseDatabaseHelper();
    	}
    	return sInstance;
    }
    
	private LicenseDatabaseHelper() {
    	sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    	sUriMatcher.addURI(
    			LicenseDatabaseMetadata.AUTHORITY, 
    			LicenseDatabaseMetadata.License.TABLE_NAME, 
    			LICENSE);
    	
    	mLicenseDatabase = LicenseDatabase.getInstance();
    	
    	SQLiteDatabase db = mLicenseDatabase.getReadableDatabase();
    	db.close();
    }
    
    public Uri insert(Uri uri, ContentValues values) {
		Uri insertedUri = null;
		String notifyUri = null;
		int match = sUriMatcher.match(uri);
		
        if (LOCAL_LOGV) {
            FxLog.v(TAG, "Insert uri=" + uri + ", match=" + match);
        }
        
    	String table = null;
        switch (match) {
        	case LICENSE:
        		table = LicenseDatabaseMetadata.License.TABLE_NAME;
        		notifyUri = LicenseDatabaseMetadata.License.URI;
        		break;
        	default:
        		throw new IllegalArgumentException("Unknown URI " + uri);
        }
        
        SQLiteDatabase db = mLicenseDatabase.getWritableDatabase();
        long rowId = db.insert(table, null, values);
        db.close();
		
		if (rowId > 0) {
			insertedUri = ContentUris.withAppendedId(Uri.parse(notifyUri), rowId);
		}
		else {
			throw new SQLException("Failed to insert row into " + uri);
		}
		return insertedUri;
	}
    
    public Cursor query(Uri uri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		// Parse selection String
    	String parseSelect = FxUtil.getSqlSelection(selection);
	    String parseLimit = FxUtil.getSqlLimit(selection);
	    
	    HashMap<String, String> sqlSettings = getSqlSettings(uri, parseSelect);
	    
	    SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
		qb.setTables(sqlSettings.get(FxUtil.SQL_TABLE_KEY));
		if (sqlSettings.get(FxUtil.SQL_SELECT_KEY) != null) {
			qb.appendWhere(sqlSettings.get(FxUtil.SQL_SELECT_KEY));
		}
		
	    // Build query String
	    String sql = qb.buildQuery(projection, parseSelect, 
	    		selectionArgs, null, null, sortOrder, parseLimit);
	
	    // Get the database and run the query
	    SQLiteDatabase db = mLicenseDatabase.getReadableDatabase();
	    Cursor cursor = db.rawQuery(sql, selectionArgs);
	
	    return cursor;
	}
    
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mLicenseDatabase.getWritableDatabase();
	    int rowAffected = db.update(
	    		sqlSettings.get(FxUtil.SQL_TABLE_KEY), 
	    		values, 
	    		sqlSettings.get(FxUtil.SQL_SELECT_KEY), 
	    		selectionArgs);
	    db.close();
	    
	    return rowAffected;
	}
	
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mLicenseDatabase.getWritableDatabase();
	    int rowAffected = db.delete(
	    		sqlSettings.get(FxUtil.SQL_TABLE_KEY), 
	    		sqlSettings.get(FxUtil.SQL_SELECT_KEY), 
	    		selectionArgs);
	    db.close();
	    
	    return rowAffected;
	}
    
	private HashMap<String, String> getSqlSettings(Uri uri, String selection) {
		String table = null;
		
		int match = sUriMatcher.match(uri);
		switch (match) {
			case LICENSE:
				table = LicenseDatabaseMetadata.License.TABLE_NAME;
				break;
		    default:
		        throw new IllegalArgumentException("Unknown URI " + uri);
		}
		HashMap<String, String> sqlSettings = new HashMap<String, String>();
		sqlSettings.put(FxUtil.SQL_TABLE_KEY, table);
		sqlSettings.put(FxUtil.SQL_SELECT_KEY, selection);
		
		return sqlSettings;
	}
}
