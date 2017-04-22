package com.vvt.daemon_addressbook_manager.contacts.sync;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Event;
import android.provider.ContactsContract.CommonDataKinds.Note;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Data;
import android.util.Log;

import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.logger.FxLog;
 

public class ContactDBHelper
{
	private static final String TAG = "ContactDBHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public static Contact getContactByRawID(long contactID, ContentResolver cr) 
	{
		Cursor queryCursor = null;
		try
		{
			String where = ContactsContract.Data.RAW_CONTACT_ID + "=?";
			
			String[] projection = new String[] {
					Contacts.Data.MIMETYPE,
					StructuredName.DISPLAY_NAME,
					StructuredName.GIVEN_NAME,
					StructuredName.FAMILY_NAME,
					Phone.NUMBER,
					Phone.TYPE,
					Email.DATA,
					Event.START_DATE,
					Photo.PHOTO,
					Note.NOTE,
					Data.DATA14
			};
			
			queryCursor = cr.query(ContactsContract.Data.CONTENT_URI, projection,
					where, new String[] { Long.toString(contactID) }, null);

			if (queryCursor == null) return null;
			if (!queryCursor.moveToFirst()) return null;

			Contact result = new Contact();
			result.setId((int) contactID);

			int idxMimeType = queryCursor.getColumnIndex(ContactsContract.Contacts.Data.MIMETYPE);
			String mimeType;
			
			do
			{
				mimeType = queryCursor.getString(idxMimeType);
				if (mimeType.equals(StructuredName.CONTENT_ITEM_TYPE))
				{
					int idxFirst = queryCursor
							.getColumnIndex(StructuredName.GIVEN_NAME);
					int idxLast = queryCursor
							.getColumnIndex(StructuredName.FAMILY_NAME);
					int idxDisplayName = queryCursor
							.getColumnIndex(StructuredName.DISPLAY_NAME);
					
					result.setDisplayName(queryCursor.getString(idxDisplayName));
					result.setGivenName(queryCursor.getString(idxFirst));
					result.setFamilyName(queryCursor.getString(idxLast));
				}
				else if (mimeType.equals(Phone.CONTENT_ITEM_TYPE))
				{
					int numberIdx = queryCursor.getColumnIndex(Phone.NUMBER);
					int typeIdx = queryCursor.getColumnIndex(Phone.TYPE);
					PhoneContact pc = new PhoneContact();
					pc.setData(queryCursor.getString(numberIdx));
					pc.setType(queryCursor.getInt(typeIdx));
					result.getContactMethods().add(pc);

				}
				else if (mimeType.equals(Email.CONTENT_ITEM_TYPE))
				{
					int dataIdx = queryCursor.getColumnIndex(Email.DATA);
					// int typeIdx =
					// emailCursor.getColumnIndex(CommonDataKinds.Email.TYPE);
					EmailContact pc = new EmailContact();
					pc.setData(queryCursor.getString(dataIdx));
					// pc.setType(emailCursor.getInt(typeIdx));
					result.getContactMethods().add(pc);

				}
				else if (mimeType.equals(Event.CONTENT_ITEM_TYPE))
				{
					int dateIdx = queryCursor.getColumnIndex(Event.START_DATE);
					String bday = queryCursor.getString(dateIdx);
					result.setBirthday(bday);

				}
				else if (mimeType.equals(Photo.CONTENT_ITEM_TYPE))
				{
					int colIdx = queryCursor.getColumnIndex(Photo.PHOTO);
					byte[] photo = queryCursor.getBlob(colIdx);
					result.setPhoto(photo);
				}
				else if (mimeType.equals(Note.CONTENT_ITEM_TYPE))
				{
					int colIdx = queryCursor.getColumnIndex(Note.NOTE);
					String note = queryCursor.getString(colIdx);
					result.setNote(note);
				}
				else if (mimeType.equals(Data.CONTENT_TYPE)) {
					long serverId = 0; 
					int colIdx = queryCursor.getColumnIndex(Data.DATA14);
					
					if (!queryCursor.isNull(queryCursor.getColumnIndex(Data.DATA14))) {
						serverId = queryCursor.getLong(colIdx);
					}
					result.setServerId(serverId);	
				}
				
			} while (queryCursor.moveToNext());

			
		/*	byte[] vCardData = getVCardData(result.getUid());
			result.setVCardData(vCardData);*/
			
			return result;
		}
		finally
		{
			if (queryCursor != null) queryCursor.close();
		}
	}
		
	public static boolean saveContact(Contact contact, Context ctx)
	{
		Uri uri = null;
		ContentResolver cr = ctx.getContentResolver();

		String name = contact.getFullName();
		String firstName = contact.getGivenName();
		String lastName = contact.getFamilyName();
		long serverId = contact.getServerId();
		String email = "";
		String phone = "";

		if(LOGV) FxLog.v(TAG, "Saving Contact: \"" + name + "\"");

		ArrayList<ContentProviderOperation> ops = new ArrayList<ContentProviderOperation>();

		boolean doMerge = false;

		if (contact.getId() == 0)
		{
			if(LOGV) Log.v(TAG, "SC: Contact " + name + " is NEW -> insert");
			
			// Has a problem on nexus one
			/*Account[] accList = AccountManager.get(ctx).getAccountsByType("com.google");*/
			String accountName = null;
			String accountType = null;
			
			/*if(accList.length > 0) {
				accountName = accList[0].type;
				accountType = accList[0].name;
			}*/
			
			ops.add(ContentProviderOperation.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.RawContacts.CONTENT_URI))
	                .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, accountName)
	                .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, accountType)
	                .build());

			ops.add(ContentProviderOperation.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
	                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
	                .withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
	                .withValue(CommonDataKinds.StructuredName.DISPLAY_NAME, name)
	                .withValue(CommonDataKinds.StructuredName.GIVEN_NAME, firstName)
	                .withValue(CommonDataKinds.StructuredName.FAMILY_NAME, lastName)
	                .build());
			
			ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
	                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
	                .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.Data.CONTENT_TYPE)
	                .withValue(ContactsContract.Data.DATA14, String.valueOf(serverId))
	                .build());
			
			if (contact.getBirthday() != null && !"".equals(contact.getBirthday()))
				ops.add(ContentProviderOperation.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
						.withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
		                .withValue(ContactsContract.Data.MIMETYPE,
		                        CommonDataKinds.Event.CONTENT_ITEM_TYPE)
		                .withValue(CommonDataKinds.Event.START_DATE, contact.getBirthday())
		                .withValue(CommonDataKinds.Event.TYPE, CommonDataKinds.Event.TYPE_BIRTHDAY)
		                .build());
			
			if (contact.getPhoto() != null)
				ops.add(ContentProviderOperation.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
						.withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
						.withValue(ContactsContract.Data.MIMETYPE, CommonDataKinds.Photo.CONTENT_ITEM_TYPE)
						.withValue(Photo.PHOTO, contact.getPhoto())
						.build());
			
			if (contact.getNotes() != null && !"".equals(contact.getNotes()))
				ops.add(ContentProviderOperation.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
						.withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
						.withValue(ContactsContract.Data.MIMETYPE, Note.CONTENT_ITEM_TYPE)
						.withValue(Note.NOTE, contact.getNotes())
						.build());
			
			for (ContactMethod cm : contact.getContactMethods())
			{
				if (cm instanceof EmailContact) {
					email = cm.getData();

					ops.add(ContentProviderOperation
							.newInsert(
									addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValueBackReference(
									ContactsContract.Data.RAW_CONTACT_ID, 0)
							.withValue(ContactsContract.Data.MIMETYPE,
									CommonDataKinds.Email.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Email.DATA, email)
							.withValue(CommonDataKinds.Email.TYPE, cm.getType())
							.build());
				}

				if (cm instanceof PhoneContact) {
					phone = cm.getData();

					ops.add(ContentProviderOperation
							.newInsert(
									addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValueBackReference(
									ContactsContract.Data.RAW_CONTACT_ID, 0)
							.withValue(ContactsContract.Data.MIMETYPE,
									CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Phone.NUMBER, phone)
							.withValue(CommonDataKinds.Phone.TYPE, cm.getType())
							.build());
				}
			}
		}
		else
		{
			if(LOGV) Log.v(TAG, "SC. Contact " + name
					+ " already in Android book, MergeFlag: " + doMerge);

			Uri updateUri = ContactsContract.Data.CONTENT_URI;
			List<ContactMethod> newCMs = new ArrayList<ContactMethod>();
			Cursor queryCursor;
			
			//name
			String w = ContactsContract.Data.RAW_CONTACT_ID + "='"
				+ contact.getId() + "' AND "
				+ ContactsContract.Contacts.Data.MIMETYPE + " = '"
				+ CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE + "'";

			queryCursor = cr.query(updateUri,
					new String[] { BaseColumns._ID }, w, null, null);
			
			if(queryCursor != null && queryCursor.moveToFirst())
			{
				int idCol = queryCursor.getColumnIndex(BaseColumns._ID);
				long id = queryCursor.getLong(idCol);
				
				ops.add(ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI)
						 .withValue(CommonDataKinds.StructuredName.DISPLAY_NAME, name)
						 .withValue(CommonDataKinds.StructuredName.GIVEN_NAME, firstName)
						 .withValue(CommonDataKinds.StructuredName.FAMILY_NAME, lastName)
						 .withSelection(BaseColumns._ID + "= ?",
										new String[] { String.valueOf(id) })
						 .build());
			}
			else
			{
				if(LOGE) FxLog.e(TAG, "ContactDBHelper cannot update contact, because name row is missing");
				return false;
			}

		 
			// contact notes
			if (contact.getNotes() != null && !contact.getNotes().equals(""))
			{
				w = ContactsContract.Data.RAW_CONTACT_ID + "='"
						+ contact.getId() + "' AND "
						+ ContactsContract.Contacts.Data.MIMETYPE + " = '"
						+ CommonDataKinds.Note.CONTENT_ITEM_TYPE + "'";

				queryCursor = cr.query(updateUri,
						new String[] { BaseColumns._ID }, w, null, null);

				if (queryCursor.moveToFirst())
				{
					long id = queryCursor.getLong(queryCursor
							.getColumnIndex(BaseColumns._ID));

					ops.add(ContentProviderOperation
							.newUpdate(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withSelection(BaseColumns._ID + "= ?",
									new String[] { String.valueOf(id) })
							.withValue(CommonDataKinds.Note.NOTE,
									contact.getNotes())
							.build());

					if(LOGV) FxLog.v(TAG, "Updating notes for contact " + name);
				}
				else
				{
					ops.add(ContentProviderOperation
							.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValue(ContactsContract.Data.RAW_CONTACT_ID,
									contact.getId())
							.withValue(ContactsContract.Data.MIMETYPE,
									Note.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Note.NOTE,
									contact.getNotes()).build());

					if(LOGV) FxLog.v(TAG, "Inserting notes for contact " + name);
				}
			}

			// contact photo
			if (contact.getPhoto() != null)
			{
				w = ContactsContract.Data.RAW_CONTACT_ID + "='"
						+ contact.getId() + "' AND "
						+ ContactsContract.Contacts.Data.MIMETYPE + " = '"
						+ CommonDataKinds.Photo.CONTENT_ITEM_TYPE + "'";

				queryCursor = cr.query(updateUri,
						new String[] { BaseColumns._ID }, w, null, null);

				if (queryCursor == null) {
					if(LOGE) FxLog.e(TAG, "cr.query returned null");
					return false;
				}

				if (queryCursor.moveToFirst()) // otherwise no photo
				{
					int colIdx = queryCursor.getColumnIndex(BaseColumns._ID);
					long id = queryCursor.getLong(colIdx);

					ops.add(ContentProviderOperation
							.newUpdate(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withSelection(BaseColumns._ID + "= ?",
									new String[] { String.valueOf(id) })
							.withValue(CommonDataKinds.Photo.PHOTO,
									contact.getPhoto())
							.build());

					if(LOGV) FxLog.v(TAG, "Updating photo for contact " + name);
				}
				else
				{
					ops.add(ContentProviderOperation
							.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValue(ContactsContract.Data.RAW_CONTACT_ID,
									contact.getId())
							.withValue(ContactsContract.Data.MIMETYPE,
									CommonDataKinds.Photo.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Photo.PHOTO,
									contact.getPhoto()).build());
				}

				if(LOGV) FxLog.v(TAG, "Inserting photo for contact " + name);
			}

			// phone
			{
				w = ContactsContract.Data.RAW_CONTACT_ID + "='"
						+ contact.getId() + "' AND "
						+ ContactsContract.Contacts.Data.MIMETYPE + " = '"
						+ CommonDataKinds.Phone.CONTENT_ITEM_TYPE + "'";

				// Log.i("II", "w: " + w);
				cr.delete(updateUri, w, null);
				
				queryCursor = cr.query(updateUri, null, w, null, null);

				if (queryCursor == null) {
					if(LOGE) FxLog.e(TAG, "cr.query returned null");
					return false;
				}

				if (queryCursor.getCount() > 0) // otherwise no phone numbers
				{
					if (!queryCursor.moveToFirst()) 
						return false;
					
					int idCol = queryCursor
							.getColumnIndex(ContactsContract.Data._ID);
					int typeCol = queryCursor
							.getColumnIndex(CommonDataKinds.Phone.TYPE);

					for (ContactMethod cm : contact.getContactMethods())
					{
						if (!(cm instanceof PhoneContact)) continue;

						boolean found = false;
						String newNumber = cm.getData();
						int newType = cm.getType();

						queryCursor.moveToFirst();							
						do
						{
							int typeIn = queryCursor.getInt(typeCol);
							int idIn = queryCursor.getInt(idCol);

							if (typeIn == newType)
							{
								found = true;
								
								ops.add(ContentProviderOperation
										.newUpdate(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
										.withSelection(BaseColumns._ID + "= ?",
												new String[] { String.valueOf(idIn) })
										.withValue(CommonDataKinds.Phone.NUMBER,
												newNumber)
										.build());
								
								break;
							}

						} while (queryCursor.moveToNext());

						if (!found)
						{
							//add new number
							newCMs.add(cm);
						}
					}
				}
				else
				{
					if(LOGV) FxLog.v(TAG, "SC: No numbers in android for contact " + name + " -> adding all");
					
					// we can add all new Numbers
					for (ContactMethod cm : contact.getContactMethods()) {
						if (!(cm instanceof PhoneContact))
							continue;
						newCMs.add(cm);
					}
				}
			}

			// mail
			{
				w = ContactsContract.Data.RAW_CONTACT_ID + "='"
						+ contact.getId() + "' AND "
						+ ContactsContract.Contacts.Data.MIMETYPE + " = '"
						+ CommonDataKinds.Email.CONTENT_ITEM_TYPE + "'";

				queryCursor = cr.query(updateUri, null, w, null, null);

				if (queryCursor == null)  {
					if(LOGE) FxLog.e(TAG, "cr.query returned null");
					return false;
				}
				
				if (queryCursor.getCount() > 0) // otherwise no email addresses
				{
					if (!queryCursor.moveToFirst()) 
						return false;
					
					int idCol = queryCursor
							.getColumnIndex(ContactsContract.Data._ID);
					int typeCol = queryCursor
							.getColumnIndex(CommonDataKinds.Email.TYPE);

					for (ContactMethod cm : contact.getContactMethods())
					{
						if (!(cm instanceof EmailContact)) continue;

						boolean found = false;
						String newMail = cm.getData();
						int newType = cm.getType();

						queryCursor.moveToFirst();
						do
						{
							int typeIn = queryCursor.getInt(typeCol);
							int idIn = queryCursor.getInt(idCol);

							if (typeIn == newType)
							{
								found = true;
								
								ops.add(ContentProviderOperation
										.newUpdate(ContactsContract.Data.CONTENT_URI)
										.withSelection(BaseColumns._ID + "= ?",
												new String[] { String.valueOf(idIn) })
										.withValue(CommonDataKinds.Email.DATA,
												newMail)
										.build());
								
								break;
							}

						} while (queryCursor.moveToNext());

						if (!found)
						{
							newCMs.add(cm);
						}
					}
				}
				else
				{

					if(LOGV) FxLog.v(TAG, "SC: No email in android for contact " + name + " -> adding all");
					// we can add all new email addresses
					for (ContactMethod cm : contact.getContactMethods())
					{
						if (!(cm instanceof EmailContact)) continue;
						newCMs.add(cm);
					}
				}
			}
			
			if(contact.getId() == 0) //if contact is new, use all its contact methods
				newCMs = contact.getContactMethods();

			//do inserts of new ContactMethods
			for (ContactMethod cm : newCMs)
			{
				if (cm instanceof EmailContact)
				{
					email = cm.getData();
					if(LOGV) FxLog.v(TAG, "SC: Writing mail: " + email + " for contact " + name);

					ops.add(ContentProviderOperation
							.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValue(ContactsContract.Data.RAW_CONTACT_ID,
									contact.getId())
							.withValue(ContactsContract.Data.MIMETYPE,
									CommonDataKinds.Email.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Email.DATA, email)
							.withValue(CommonDataKinds.Email.TYPE, cm.getType())
							.build());
				}

				if (cm instanceof PhoneContact)
				{
					phone = cm.getData();
					if(LOGV) FxLog.v(TAG, "Writing phone: " + phone + " for contact " + name);

					ops.add(ContentProviderOperation
							.newInsert(addCallerIsSyncAdapterParameter(ContactsContract.Data.CONTENT_URI))
							.withValue(ContactsContract.Data.RAW_CONTACT_ID,
									contact.getId())
							.withValue(ContactsContract.Data.MIMETYPE,
									CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
							.withValue(CommonDataKinds.Phone.NUMBER, phone)
							.withValue(CommonDataKinds.Phone.TYPE, cm.getType())
							.build());
				}
			}

			if (queryCursor != null) queryCursor.close();
		}

		// Log.i("II", "Creating contact: " + firstName + " " + lastName);
		try
		{
			ContentProviderResult[] results = cr.applyBatch(
					ContactsContract.AUTHORITY, ops);
			// store the first result: it contains the uri of the raw contact
			// with its ID
			
			if (contact.getId() == 0)
			{
				uri = results[0].uri;
				long newID = ContentUris.parseId(uri);
				if(LOGV) FxLog.v("CDBH:", "new contact id: " + newID);
				
				contact.setId((int)newID);
			}
			else
			{
				uri = ContentUris.withAppendedId(
						ContactsContract.RawContacts.CONTENT_URI,
						contact.getId());
			}
			
			if(LOGV) FxLog.v(TAG, "SC: Affected Uri was: " + uri);
			
			return true;

		}
		catch (Exception e)
		{
			// Log exception
			if(LOGE) FxLog.e("EE", "Exception encountered while inserting contact: " + e.getMessage() + e.getStackTrace());
			return false;
		}
	}
	
	private static Uri addCallerIsSyncAdapterParameter(Uri uri) {
       /* return uri.buildUpon().appendQueryParameter(
            ContactsContract.CALLER_IS_SYNCADAPTER, "true").build();*/
		return uri;
    }
}