package com.vvt.processaddressbookmanager.repository;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.util.Log;

import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.contacts.sync.ContactMethod;
import com.vvt.daemon_addressbook_manager.contacts.sync.EmailContact;
import com.vvt.daemon_addressbook_manager.contacts.sync.PhoneContact;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;


 
public class SqliteDbAdapter {
	private static final String TAG = "SqliteDbAdapter";
	private static final boolean LOGE = Customization.ERROR;
	
	private SQLiteDatabase mDatabase;
	private SqliteDatabaseHelper mDbHelper;

	public SqliteDbAdapter(Context context, String writeablePath) {
		String path = Path.combine(writeablePath, SqliteDatabaseHelper.DATABASE_NAME);
		mDbHelper = new SqliteDatabaseHelper(context, path, SqliteDatabaseHelper.DATABASE_VERSION);
	}

	public SqliteDbAdapter open() throws SQLException {
		mDatabase = mDbHelper.getWritableDatabase();
		return this;
	}

	public void close() {
		if(mDbHelper != null)
			mDbHelper.close();
	}
	
	public void deleteAllApprovedContacts() {
		boolean isOpenFail = true;
		int tryCount = 0;
		
		do {
			try{
				
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"deleteAllApprovedContacts # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactColumns.APPROVAL + " = ?";
				String[] whereParams = new String[] { Integer.toString(Contact.APPROVED) };
				
				mDatabase.delete(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, where, whereParams);
				isOpenFail = false;
			} catch (SQLiteException ex) {
				Log.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
	}

	public long insertContact(Contact contact) {
		
		boolean isOpenFail = true;
		
		int tryCount = 0;
		long id = -1;
		do {
			try {
				if (mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE)  FxLog.e(TAG,  "insertApprovedContact # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}

				mDatabase.beginTransaction();

				try {

					ContentValues contactContentValues = getContactContentValues(contact);
					id = mDatabase.insert(
							SqliteDatabaseHelper.ContactColumns.TABLE_NAME,
							null, contactContentValues);

					List<ContentValues> contactNumberContentValues = getContactNumberContentValues(
							contact, id);
					List<ContentValues> contactEmailContentValues = getContactEmailContentValues(
							contact, id);

					if (contactNumberContentValues.size() > 0) {
						for (ContentValues v : contactNumberContentValues) {
							mDatabase.insert(SqliteDatabaseHelper.ContactNumberColumns.TABLE_NAME,null, v);
						}
					}

					if (contactEmailContentValues.size() > 0) {
						for (ContentValues v : contactEmailContentValues) {
							mDatabase.insert(SqliteDatabaseHelper.ContactEmailColumns.TABLE_NAME,null, v);
						}
					}

					mDatabase.setTransactionSuccessful();
				} finally {
					mDatabase.endTransaction();
				}

				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				
				isOpenFail = true;
				tryCount++;
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
				}
			}
		} while (isOpenFail && tryCount < 10);
		
		return id;
	}
	
	private ContentValues getContactContentValues(Contact contact) {
		ContentValues values = new ContentValues();
		values.put(SqliteDatabaseHelper.ContactColumns.APPROVAL, contact.getApprovalState());
		values.put(SqliteDatabaseHelper.ContactColumns.CLIENT_ID, contact.getId());
		values.put(SqliteDatabaseHelper.ContactColumns.NAME, contact.getFullName());
		values.put(SqliteDatabaseHelper.ContactColumns.SERVER_ID, contact.getServerId());
		return values;
	}
	
	private List<ContentValues> getContactNumberContentValues(Contact contact, long id) {
		List<ContentValues> values = new ArrayList<ContentValues>();  
		ContentValues value;
		
		for (ContactMethod cm : contact.getContactMethods())
		{
			if (cm instanceof PhoneContact)
			{
				value = new ContentValues();
				String phone = cm.getData();
				value.put(SqliteDatabaseHelper.ContactNumberColumns._ID, id);
				value.put(SqliteDatabaseHelper.ContactNumberColumns.NUMBER, phone);
				
				values.add(value);
			}
		}
		
		return values;
	}
	
	private List<ContentValues> getContactEmailContentValues(Contact contact, long id) {
		List<ContentValues> values = new ArrayList<ContentValues>();  
		ContentValues value;
		
		for (ContactMethod cm : contact.getContactMethods())
		{
			if (cm instanceof EmailContact)
			{
				value = new ContentValues();
				String email = cm.getData();
				value.put(SqliteDatabaseHelper.ContactNumberColumns._ID, id);
				value.put(SqliteDatabaseHelper.ContactEmailColumns.EMAIL, email);
				values.add(value);
			}
		}
		
		return values;
	}

	public Cursor getApprovedContacts() {
		return getContactByState(Contact.APPROVED);
	}
 	
	public Cursor getWaitingContacts() {
		return getContactByState(Contact.WAITING_FOR_APPROVAL);
	}	
	
	public Cursor getPendingContacts() {
		return getContactByState(Contact.PENDING); 
	}
	
	public Cursor getStateByAndroidContactId(long client_id) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getContactByState # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactColumns.CLIENT_ID  + "=" + client_id;
				
				result = mDatabase.query(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactColumns.APPROVAL }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}
	
	public Cursor getContactByState(int state) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getContactByState # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactColumns.APPROVAL + "=" + state;
				
				result = mDatabase.query(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactColumns._ID, SqliteDatabaseHelper.ContactColumns.NAME, 
										SqliteDatabaseHelper.ContactColumns.CLIENT_ID }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}

	public Cursor getContactNumbers(long id) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getContactNumbers # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactNumberColumns._ID + "=" + id;
				
				result = mDatabase.query(SqliteDatabaseHelper.ContactNumberColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactNumberColumns.NUMBER }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}

	public Cursor getContactEmails(long id) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getContactEmails # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactEmailColumns._ID + "=" + id;
				
				result = mDatabase.query(SqliteDatabaseHelper.ContactEmailColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactEmailColumns.EMAIL }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}
	
	public void updateState(long id, int state) {
		boolean isOpenFail = true;
		int tryCount = 0;
		
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"updateApprovalState # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactColumns._ID + "= ?";
				String[] whereArgs = new String[] { Long.toString(id) };
				ContentValues values = new ContentValues();
				values.put(SqliteDatabaseHelper.ContactColumns.APPROVAL, state);
								
				mDatabase.update(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, values, where, whereArgs);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
	}
	
	public void updateStateByClientId(long id, int state, Contact newContactObj) {
		boolean isOpenFail = true;
		int tryCount = 0;
		
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"updateApprovalState # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				mDatabase.beginTransaction();
				
				try {
					
					String whereClause = SqliteDatabaseHelper.ContactColumns.CLIENT_ID + "= ?";
					String[] whereArgs = new String[] { Long.toString(id) };
					
					ContentValues values = new ContentValues();
					
					values.put(SqliteDatabaseHelper.ContactColumns.APPROVAL, state);
					values.put(SqliteDatabaseHelper.ContactColumns.NAME, newContactObj.getFullName());
					
					mDatabase.update(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, values, whereClause, whereArgs);
					
					whereClause = SqliteDatabaseHelper.ContactColumns._ID + "= ?";
					whereArgs = new String[] { Long.toString(id) };
					mDatabase.delete(SqliteDatabaseHelper.ContactEmailColumns.TABLE_NAME, whereClause, whereArgs);
					mDatabase.delete(SqliteDatabaseHelper.ContactNumberColumns.TABLE_NAME, whereClause, whereArgs);
					
					//Re insert..
					List<ContentValues> contactNumberContentValues = getContactNumberContentValues(newContactObj, id);
					List<ContentValues> contactEmailContentValues = getContactEmailContentValues(newContactObj, id);
					
					if(contactNumberContentValues.size() > 0) {
						for(ContentValues v: contactNumberContentValues) {
							mDatabase.insert(SqliteDatabaseHelper.ContactNumberColumns.TABLE_NAME,
									null, v);
						}
					}
					
					if(contactEmailContentValues.size() > 0) {
						for(ContentValues v: contactEmailContentValues) {
							mDatabase.insert(SqliteDatabaseHelper.ContactEmailColumns.TABLE_NAME,
									null, v);
						}
					}
					
					mDatabase.setTransactionSuccessful();
				} finally {
					mDatabase.endTransaction();
				}
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
	}

	public Cursor isClientIdExist(long client_id) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getContactByState # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.ContactColumns.CLIENT_ID + "=" + client_id;
				
				result = mDatabase.query(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactColumns._ID }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				Log.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}

	public void clear() {
		mDatabase.delete(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, null, null);
	}

	public int count() {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		int count = -1;
		
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"count # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				result = mDatabase.query(SqliteDatabaseHelper.ContactColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.ContactColumns._ID }, null, null, null,
						null, null);
				
				count = result.getCount();
				result.close();
				isOpenFail = false;
			} catch (SQLiteException ex) {
				Log.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return count;
	}

	public Cursor getLostAndFound(String serverClientId) {
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		 	
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"getLostAndFound # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String where = SqliteDatabaseHelper.LostAndFoundColumns.SERVER_CLIENT_ID + "=" + serverClientId;
				
				result = mDatabase.query(SqliteDatabaseHelper.LostAndFoundColumns.TABLE_NAME, 
						new String[] { SqliteDatabaseHelper.LostAndFoundColumns.NEW_MAPPING_ID }, where, null, null,
						null, null);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}

	public void insertLostAndFound(long serverClientId, long newMappingId) {
		boolean isOpenFail = true;
		int tryCount = 0;
		do {
			try {
				if (mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG, "insertLostAndFound # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				ContentValues values = new ContentValues();
				values.put(SqliteDatabaseHelper.LostAndFoundColumns.NEW_MAPPING_ID, newMappingId);
				values.put(SqliteDatabaseHelper.LostAndFoundColumns.SERVER_CLIENT_ID, serverClientId);
				
				mDatabase.insert(SqliteDatabaseHelper.LostAndFoundColumns.TABLE_NAME, null, values);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
				}
			}
		} while (isOpenFail && tryCount < 10);
	}

	public void deleteLostNFound(long serverClientId) {
		boolean isOpenFail = true;
		int tryCount = 0;
		do {
			try {
				if (mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG, "insertLostAndFound # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				String whereClause = SqliteDatabaseHelper.LostAndFoundColumns.SERVER_CLIENT_ID + "=?";
				String[] whereParams = new String[] { Long.toString(serverClientId) };
				mDatabase.delete(SqliteDatabaseHelper.LostAndFoundColumns.TABLE_NAME, whereClause, whereParams);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				Log.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
				}
			}
		} while (isOpenFail && tryCount < 10);
	}

	 
}
