package com.vvt.processaddressbookmanager.monitor;

import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Note;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Contacts.Data;

public class AddressBookDatabaseHelper {
	 /**
     * Normally used for observing
     */
    public static final Uri CONTENT_URI = ContactsContract.RawContactsEntity.CONTENT_URI;
    
    public static final String[] PROJECTION = new String[] {
			Data.RAW_CONTACT_ID, StructuredName.DISPLAY_NAME,
			StructuredName.GIVEN_NAME, StructuredName.FAMILY_NAME,
			Contacts.LOOKUP_KEY };
    
    public static final String BASE_SELECTION = new StringBuilder().append(
            Contacts.LOOKUP_KEY).append("=?").append(" AND ").append(
            Data.MIMETYPE).append("='").toString();
    
    public static final String NAME_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(StructuredName.CONTENT_ITEM_TYPE)
            .append("'").toString();
    
    public static final String NUMBER_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(Phone.CONTENT_ITEM_TYPE).append("'")
            .toString();
    public static final String EMAIL_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(Email.CONTENT_ITEM_TYPE).append("'")
            .toString();
    public static final String NOTE_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(Note.CONTENT_ITEM_TYPE).append("'")
            .toString();
    public static final String PHOTO_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(Photo.CONTENT_ITEM_TYPE).append("'")
            .toString();
    public static final String DATA_SELECTION = new StringBuilder().append(
            BASE_SELECTION).append(Photo.CONTENT_ITEM_TYPE).append("'")
            .toString();
    
}
