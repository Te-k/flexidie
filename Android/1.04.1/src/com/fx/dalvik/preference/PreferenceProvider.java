package com.fx.dalvik.preference;

import java.util.HashMap;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import com.fx.dalvik.util.FxLog;

import com.vvt.android.syncmanager.Customization;

public class PreferenceProvider extends ContentProvider {
	
	private static final String TAG = "PreferenceProvider";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;

    private static final int CONNECTION_HISTORY = 1;
    private static final int CONNECTION_HISTORY_ID = 2;
    
    public static final String SQL_TABLE_KEY = "table";
    public static final String SQL_SELECT_KEY = "selection";
    private static final String SQL_SEPARATOR = "###";
    
    private UriMatcher sUriMatcher;
	private PreferenceDatabaseHelper mPreferenceDatabaseHelper;
    
    @Override
	public boolean onCreate() {
    	sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    	
    	sUriMatcher.addURI(
    			PreferenceDatabaseMetadata.AUTHORITY, 
    			PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME, 
    			CONNECTION_HISTORY);
    	
    	mPreferenceDatabaseHelper = PreferenceDatabaseHelper.getInstance(getContext());
    	
		return true;
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
        	case CONNECTION_HISTORY:
        		table = PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME;
        		notifyUri = PreferenceDatabaseMetadata.ConnectionHistory.URI;
        		break;
        	default:
        		throw new IllegalArgumentException("Unknown URI " + uri);
        }
        
        SQLiteDatabase db = mPreferenceDatabaseHelper.getWritableDatabase();
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
    	String parseSelect = getSqlSelection(selection);
	    String parseLimit = getSqlLimit(selection);
	    
	    HashMap<String, String> sqlSettings = getSqlSettings(uri, parseSelect);
	    
	    SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
		qb.setTables(sqlSettings.get(SQL_TABLE_KEY));
		if (sqlSettings.get(SQL_SELECT_KEY) != null) {
			qb.appendWhere(sqlSettings.get(SQL_SELECT_KEY));
		}
		
	    // Build query String
	    String sql = qb.buildQuery(projection, parseSelect, 
	    		selectionArgs, null, null, sortOrder, parseLimit);
	
	    // Get the database and run the query
	    SQLiteDatabase db = mPreferenceDatabaseHelper.getReadableDatabase();
	    Cursor cursor = db.rawQuery(sql, selectionArgs);
	
	    return cursor;
	}
    
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mPreferenceDatabaseHelper.getWritableDatabase();
	    int rowAffected = db.update(
	    		sqlSettings.get(SQL_TABLE_KEY), 
	    		values, 
	    		sqlSettings.get(SQL_SELECT_KEY), 
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
	    
		SQLiteDatabase db = mPreferenceDatabaseHelper.getWritableDatabase();
	    int rowAffected = db.delete(
	    		sqlSettings.get(SQL_TABLE_KEY), 
	    		sqlSettings.get(SQL_SELECT_KEY), 
	    		selectionArgs);
	    db.close();
	    
	    return rowAffected;
	}

	@Override
	public String getType(Uri uri) {
		switch (sUriMatcher.match(uri)) {
			case CONNECTION_HISTORY:
				return PreferenceDatabaseMetadata.VND_ANDROID_DIR_PREF;
			case CONNECTION_HISTORY_ID:
				return PreferenceDatabaseMetadata.VND_ANDROID_PREF;
			default:
				throw new IllegalArgumentException("Unknown URI " + uri);
		}
	}
	
	private HashMap<String, String> getSqlSettings(Uri uri, String selection) {
		String table = null;
		
		int match = sUriMatcher.match(uri);
		switch (match) {
			case CONNECTION_HISTORY:
				table = PreferenceDatabaseMetadata.ConnectionHistory.TABLE_NAME;
		        break;
		    default:
		        throw new IllegalArgumentException("Unknown URI " + uri);
		}
		HashMap<String, String> sqlSettings = new HashMap<String, String>();
		sqlSettings.put(SQL_TABLE_KEY, table);
		sqlSettings.put(SQL_SELECT_KEY, selection);
		
		return sqlSettings;
	}
	
	/**
	 * The result String will contains only SELECT clause e.g. "RowID=?"
	 */
	private String getSqlSelection(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] split = selection.split(SQL_SEPARATOR);
			return split[0].length() == 0 ? null : split[0];
		}
	}
	
	/**
	 * The result String will contains only LIMIT clause e.g. "50, 0"
	 */
	private String getSqlLimit(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] limit = selection.split(SQL_SEPARATOR);
			return limit.length > 1 ? selection.split(SQL_SEPARATOR)[1] : null;
		}
	}
}
