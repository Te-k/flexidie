package com.fx.dalvik.eventdb;

import java.util.HashMap;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.text.TextUtils;
import com.fx.dalvik.util.FxLog;

import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.DatabaseManager;

public class EventProvider extends ContentProvider {
	
	private static final String TAG = "DeviceEventProvider";
	private static final boolean LOCAL_DEBUG = false;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? LOCAL_DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? LOCAL_DEBUG : false;
	
	private static final int CALL = 1;
    private static final int CALL_ID = 2;
    private static final int SMS = 3;
    private static final int SMS_ID = 4;
    private static final int EMAIL = 5;
    private static final int EMAIL_ID = 6;
    private static final int LOC = 7;
    private static final int LOC_ID = 8;
    private static final int SYS = 9;
    private static final int SYS_ID = 10;
    
    private static UriMatcher sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    
    private SQLiteOpenHelper mOpenHelper;
    private final String TABLE_KEY = "table";
    private final String SELECT_KEY = "selection";
    
    static {
    	sUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Call.TABLE_NAME, 
    			CALL);
    	sUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Call.TABLE_NAME + "/#", 
    			CALL_ID);
    	sUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Sms.TABLE_NAME, 
    			SMS);
    	sUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Sms.TABLE_NAME + "/#", 
    			SMS_ID);
    	sUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Email.TABLE_NAME, 
    			EMAIL);
    	sUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Email.TABLE_NAME + "/#", 
    			EMAIL_ID);
    	sUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Location.TABLE_NAME, 
    			LOC);
    	sUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Location.TABLE_NAME + "/#", 
    			LOC_ID);
    	sUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.System.TABLE_NAME, 
    			SYS);
    	sUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.System.TABLE_NAME + "/#", 
    			SYS_ID);
    }

	@Override
	public boolean onCreate() {
		mOpenHelper = EventDatabaseHelper.getInstance(getContext());
		return true;
	}

	@Override
	public String getType(Uri uri) {
		switch (sUriMatcher.match(uri)) {
			case CALL:
			case SMS:
			case EMAIL:
			case LOC:
			case SYS:
				return EventDatabaseMetadata.VND_ANDROID_DIR_EVENT;
			case CALL_ID:
			case SMS_ID:
			case EMAIL_ID:
			case LOC_ID:
			case SYS_ID:
				return EventDatabaseMetadata.VND_ANDROID_EVENT;
			default:
				throw new IllegalArgumentException("Unknown URI " + uri);
		}
	}

	@Override
	public Uri insert(Uri uri, ContentValues values) {
		Uri insertedUri = null;
		Uri notifyUri = null;
		int match = sUriMatcher.match(uri);
        if (LOCAL_LOGV) {
            FxLog.v(TAG, "Insert uri=" + uri + ", match=" + match);
        }
    	String table = null;
        switch (match) {
        	case CALL:
        		table = EventDatabaseMetadata.Call.TABLE_NAME;
        		notifyUri = Uri.parse(EventDatabaseMetadata.Call.URI);
        		break;
        	case SMS:
        		table = EventDatabaseMetadata.Sms.TABLE_NAME;
        		notifyUri = Uri.parse(EventDatabaseMetadata.Sms.URI);
        		break;
        	case EMAIL:
        		table = EventDatabaseMetadata.Email.TABLE_NAME;
        		notifyUri = Uri.parse(EventDatabaseMetadata.Email.URI);
        		break;	
        	case LOC:
        		table = EventDatabaseMetadata.Location.TABLE_NAME;
        		notifyUri = Uri.parse(EventDatabaseMetadata.Location.URI);
        		break;
        	case SYS:
        		table = EventDatabaseMetadata.System.TABLE_NAME;
        		notifyUri = Uri.parse(EventDatabaseMetadata.System.URI);
        		break;
        	default:
        		throw new IllegalArgumentException("Unknown URI " + uri);
        }
        SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		
        long rowId = db.insert(table, null, values);
		
		if (rowId > 0) {
			insertedUri = ContentUris.withAppendedId(notifyUri, rowId);
			getContext().getContentResolver().notifyChange(insertedUri, null);
		}
		else {
			throw new SQLException("Failed to insert row into " + uri);
		}
		return insertedUri;
	}

	@Override
	public Cursor query(Uri uri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		// Parse selection String
	    String parseSelect = DatabaseManager.getSelection(selection);
	    String parseLimit = DatabaseManager.getLimit(selection);
	    
	    HashMap<String, String> sqlSettings = getSqlSettings(uri, parseSelect);
	    
	    SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
		qb.setTables(sqlSettings.get(TABLE_KEY));
		if (sqlSettings.get(SELECT_KEY) != null) {
			qb.appendWhere(sqlSettings.get(SELECT_KEY));
		}
		
		 // If no sort order is specified, use the default
	    String sortOrderString;
	    if (TextUtils.isEmpty(sortOrder)) {
	    	sortOrderString = EventDatabaseMetadata.DEFAULT_SORT_ORDER;
	    }
	    else {
	    	sortOrderString = sortOrder;
	    }
	    
	    // Build query String
	    String sql = qb.buildQuery(projection, parseSelect, 
	    		selectionArgs, null, null, sortOrderString, parseLimit);
	
	    // Get the database and run the query
	    SQLiteDatabase db = mOpenHelper.getReadableDatabase();
	    Cursor cursor = db.rawQuery(sql, selectionArgs);
	
	    // Tell the cursor what URI to watch, so it knows when its source data changes
	    cursor.setNotificationUri(getContext().getContentResolver(), uri);
	    return cursor;
	}

	@Override
	public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();
	    int rowAffected = db.update(
	    		sqlSettings.get(TABLE_KEY), 
	    		values, 
	    		sqlSettings.get(SELECT_KEY), 
	    		selectionArgs);
	    
	    getContext().getContentResolver().notifyChange(uri, null);
	    
	    return rowAffected;
	}
	
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mOpenHelper.getWritableDatabase();
	    int rowAffected = db.delete(
	    		sqlSettings.get(TABLE_KEY), 
	    		sqlSettings.get(SELECT_KEY), 
	    		selectionArgs);
	    
	    getContext().getContentResolver().notifyChange(uri, null);
	    
	    return rowAffected;
	}
	
	private HashMap<String, String> getSqlSettings(Uri uri, String selection) {
		String table = null;
		
		int match = sUriMatcher.match(uri);
		switch (match) {
			case CALL:
				table = EventDatabaseMetadata.Call.TABLE_NAME;
				break;
			case CALL_ID:
				table = EventDatabaseMetadata.Call.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
		        		+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
		    case SMS:
		    	table = EventDatabaseMetadata.Sms.TABLE_NAME;
		    	break;
		    case SMS_ID:
		        table = EventDatabaseMetadata.Sms.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
        				+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
		    case EMAIL:
		    	table = EventDatabaseMetadata.Email.TABLE_NAME;
		    	break;
		    case EMAIL_ID:
		        table = EventDatabaseMetadata.Email.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
        				+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
		    case LOC:
		    	table = EventDatabaseMetadata.Location.TABLE_NAME;
		        break;
		    case LOC_ID:
		        table = EventDatabaseMetadata.Location.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
						+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
		    case SYS:
		    	table = EventDatabaseMetadata.System.TABLE_NAME;
		        break;
		    case SYS_ID:
		        table = EventDatabaseMetadata.System.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
						+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
		    default:
		        throw new IllegalArgumentException("Unknown URI " + uri);
		}
		HashMap<String, String> sqlSettings = new HashMap<String, String>();
		sqlSettings.put(TABLE_KEY, table);
		sqlSettings.put(SELECT_KEY, selection);
		
		return sqlSettings;
	}
}
