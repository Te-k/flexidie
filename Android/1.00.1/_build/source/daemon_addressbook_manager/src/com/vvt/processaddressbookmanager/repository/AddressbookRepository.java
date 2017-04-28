package com.vvt.processaddressbookmanager.repository;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;

import com.vvt.daemon_addressbook_manager.ApprovedContact;
import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.delivery.KeyValuePair;
import com.vvt.processaddressbookmanager.repository.SqliteDatabaseHelper.ContactColumns;
import com.vvt.processaddressbookmanager.repository.SqliteDatabaseHelper.ContactEmailColumns;
import com.vvt.processaddressbookmanager.repository.SqliteDatabaseHelper.ContactNumberColumns;
import com.vvt.processaddressbookmanager.repository.SqliteDatabaseHelper.LostAndFoundColumns;


/**
 * @author Aruna
 * @version 1.0
 * @created 07-Oct-2011 03:23:44
 */
public class AddressbookRepository {
	private Context mContext;
	private String mWriteablePath;
	
	public AddressbookRepository(Context context, String writeablePath) {
		mContext = context;
		mWriteablePath = writeablePath;
	}
	
	public List<KeyValuePair<Long, Long>> getPendingContactIds() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		List<KeyValuePair<Long, Long>> ids = new ArrayList<KeyValuePair<Long, Long>>();
		KeyValuePair<Long, Long> pair;
		
		try {
			adpter.open();

			Cursor cursor = adpter.getPendingContacts();

			if (cursor != null) {
				while (cursor.moveToNext()) {
					long id = cursor.getLong(cursor.getColumnIndex(SqliteDatabaseHelper.ContactColumns._ID));
					long contact_id = cursor.getLong(cursor.getColumnIndex(SqliteDatabaseHelper.ContactColumns.CLIENT_ID));
					
					pair = new KeyValuePair<Long, Long>(id, contact_id);
					ids.add(pair);
				}

				cursor.close();
			}
		} finally {
			adpter.close();
		}

		return ids;
	}
	
	// Written for testing only!
	public List<KeyValuePair<Long, Long>> getWaitingContactIds() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		List<KeyValuePair<Long, Long>> ids = new ArrayList<KeyValuePair<Long, Long>>();
		KeyValuePair<Long, Long> pair;
		
		try {
			adpter.open();

			Cursor cursor = adpter.getWaitingContacts();

			if (cursor != null) {
				while (cursor.moveToNext()) {
					long id = cursor.getLong(cursor.getColumnIndex(SqliteDatabaseHelper.ContactColumns._ID));
					long contact_id = cursor.getLong(cursor.getColumnIndex(SqliteDatabaseHelper.ContactColumns.CLIENT_ID));
					
					pair = new KeyValuePair<Long, Long>(id, contact_id);
					ids.add(pair);
				}

				cursor.close();
			}
		} finally {
			adpter.close();
		}

		return ids;
	}
	
	public List<ApprovedContact> getApprovedContacts() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		List<ApprovedContact> addressBook = new ArrayList<ApprovedContact>();

		try {
			adpter.open();
			
			Cursor approvedContactCursor =  adpter.getApprovedContacts();
			ApprovedContact approvedContact = null;
				
			if(approvedContactCursor != null) {
				while (approvedContactCursor.moveToNext()) {
					
					long id = approvedContactCursor.getLong(approvedContactCursor.getColumnIndex(ContactColumns._ID));
					String displayName = approvedContactCursor.getString(approvedContactCursor.getColumnIndex(ContactColumns.NAME));
					
					approvedContact = new ApprovedContact();
					approvedContact.setDisplayName(displayName);
					
					Cursor approvedContactNumberCursor = adpter.getContactNumbers(id);
					if(approvedContactNumberCursor != null) {
						while (approvedContactNumberCursor.moveToNext()) {
							String number = approvedContactNumberCursor.getString(approvedContactNumberCursor.getColumnIndex(ContactNumberColumns.NUMBER));
							approvedContact.addNumber(number);
						}
						
						approvedContactNumberCursor.close();
					}
					
					Cursor approvedcontactEmailCursor = adpter.getContactEmails(id);
					if(approvedcontactEmailCursor != null) {
						while (approvedcontactEmailCursor.moveToNext()) {
							String email = approvedcontactEmailCursor.getString(approvedcontactEmailCursor.getColumnIndex(ContactEmailColumns.EMAIL));
							approvedContact.addEmail(email);
						}
						
						approvedcontactEmailCursor.close();
					}
				}
				
				approvedContactCursor.close();
			}
		}
		finally {
			adpter.close();
		}

		return addressBook;
	}

	public void deleteAllApprovedContacts() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.deleteAllApprovedContacts();
		}
		finally {
			adpter.close();
		}
	}

	public void insertContact(Contact contact) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.insertContact(contact);
		}
		finally {
			adpter.close();
		}
	}
	
	public void updateStateFromDeliveringToWaiting() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
	
			Cursor deliveringContactCursor =  adpter.getContactByState(Contact.DELIVERING);
			if(deliveringContactCursor != null) {
				while (deliveringContactCursor.moveToNext()) {
					long id = deliveringContactCursor.getLong(deliveringContactCursor.getColumnIndex(ContactColumns._ID));
					adpter.updateState(id, Contact.WAITING_FOR_APPROVAL);
				}
				
				deliveringContactCursor.close();
			}
		}
		finally {
			adpter.close();
		}
	}
	
	public void updateStateFromDeliveringToPending() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
	
			Cursor deliveringContactCursor =  adpter.getContactByState(Contact.DELIVERING);
			if(deliveringContactCursor != null) {
				while (deliveringContactCursor.moveToNext()) {
					long id = deliveringContactCursor.getLong(deliveringContactCursor.getColumnIndex(ContactColumns._ID));
					adpter.updateState(id, Contact.PENDING);
				}
				
				deliveringContactCursor.close();
			}
		}
		finally {
			adpter.close();
		}
		
	}
	 
	public void updateState(List<Long> sentlist, int state) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			
			for(Long id: sentlist) {
				adpter.updateState(id, state);
			}
		}
		finally {
			adpter.close();
		}
	}

	public void updateState(long id, int state) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.updateState(id, state);
		}
		finally {
			adpter.close();
		}
	}
	
	public void updateStateByClientId(long clientId, int state, Contact newContactObj) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.updateStateByClientId(clientId, state, newContactObj);
		}
		finally {
			adpter.close();
		}
	}

	public boolean isContactInWaitingState(long id) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		boolean isWaiting = false;
		
		try {
			adpter.open();
			Cursor stateCursor =  adpter.getStateByAndroidContactId(id);
			
			if(stateCursor != null) {
				stateCursor.moveToFirst();
				
				int state = stateCursor.getInt(stateCursor
						.getColumnIndex(ContactColumns.APPROVAL));

				if (state == Contact.WAITING_FOR_APPROVAL) {
					isWaiting = true;
				}
			 
				stateCursor.close();
			}
		}
		finally {
			adpter.close();
		}
		
		return isWaiting;
	}

	public boolean hasRequest(long id) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		boolean hasRequest = false;
		
		try {
			adpter.open();
			Cursor stateCursor =  adpter.getStateByAndroidContactId(id);
			
			if(stateCursor != null && stateCursor.moveToFirst()) {
				hasRequest = stateCursor.getCount() > 0;
				stateCursor.close();
			}
			
			if(stateCursor != null && !stateCursor.isClosed())
				stateCursor.close();
		}
		finally {
			adpter.close();
		}
		
		return hasRequest;
	}

	public boolean isClientIdExist(long id) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		boolean hasRequest = false;
		
		try {
			adpter.open();
			Cursor stateCursor =  adpter.isClientIdExist(id);
			
			if(stateCursor != null && stateCursor.moveToFirst()) {
				hasRequest = stateCursor.getCount() > 0;
				stateCursor.close();
			}
			
			if(stateCursor != null && !stateCursor.isClosed())
				stateCursor.close();
		}
		finally {
			adpter.close();
		}
		
		return hasRequest;
	}
	
	// Added for testing purpose only .
	public void clear() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		 
		try {
			adpter.open();
			adpter.clear();
			
		}
		finally {
			adpter.close();
		}
	}
	
	public int count() {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		int count = -1;
		
		try {
			adpter.open();
			count = adpter.count();
		}
		finally {
			adpter.close();
		}
		
		return count;
	}

	public boolean isClientIdExistInLostAndFound(String addressbookId) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		boolean hasRequest = false;
		
		try {
			adpter.open();
			Cursor stateCursor =  adpter.getLostAndFound(addressbookId);
			
			if(stateCursor != null && stateCursor.moveToFirst()) {
				hasRequest = stateCursor.getCount() > 0;
				stateCursor.close();
			}
			
			if(stateCursor != null && !stateCursor.isClosed())
				stateCursor.close();
		}
		finally {
			adpter.close();
		}
		
		return hasRequest;
	}

	public long getLostNFoundClientId(String addressbookId) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		long newMappingId = -1;
		
		try {
			adpter.open();
			Cursor stateCursor =  adpter.getLostAndFound(addressbookId);
			
			if(stateCursor != null && stateCursor.moveToFirst()) {
				newMappingId = stateCursor.getInt(stateCursor.getColumnIndex(LostAndFoundColumns.NEW_MAPPING_ID));
				stateCursor.close();
			}
			
			if(stateCursor != null && !stateCursor.isClosed())
				stateCursor.close();
		}
		finally {
			adpter.close();
		}
		
		return newMappingId;
	}

	public void insertLostNFound(long serverClientId, long newMappingId) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.insertLostAndFound(serverClientId, newMappingId);
		}
		finally {
			adpter.close();
		}
	}
	
	public void deleteLostNFound(long serverClientId) {
		SqliteDbAdapter adpter = new SqliteDbAdapter(mContext, mWriteablePath);
		
		try {
			adpter.open();
			adpter.deleteLostNFound(serverClientId);
		}
		finally {
			adpter.close();
		}
	}


}