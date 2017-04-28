package com.fx.dalvik.contacts;

import android.net.Uri;
import android.provider.CallLog;

public class ContactsDatabaseHelper {
	
	public static final Uri CALL_LOG_CONTENT_URI = CallLog.Calls.CONTENT_URI;
	
	public static final String TABLE_CALLS = "calls";
	public static final String TABLE_DATA = "data";
	public static final String TABLE_PHONES = "phones";
	public static final String TABLE_PEOPLE = "people";
	public static final String TABLE_CONTACT_METHODS = "contact_methods";
	public static final String TABLE_PHONE_LOOKUP = "phone_lookup";
	public static final String TABLE_NAME_LOOKUP = "name_lookup";
	public static final String TABLE_RAW_CONTACTS = "raw_contacts";
	
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_PERSON = "person";
	public static final String COLUMN_DATA = "data";
	public static final String COLUMN_DATA_ID = "data_id";
	public static final String COLUMN_DATA_1 = "data1";
	public static final String COLUMN_NUMBER = "number";
	public static final String COLUMN_DATE = "date";
	public static final String COLUMN_DURATION = "duration";
	public static final String COLUMN_TYPE = "type";
	public static final String COLUMN_NEW = "new";
	public static final String COLUMN_NAME = "name";
	public static final String COLUMN_NUMBERTYPE = "numbertype";
	public static final String COLUMN_NUMBERLABEL = "numberlabel";
	
	public static final String COLUMN_CONTACT_ID = "contact_id";
	public static final String COLUMN_RAW_CONTACT_ID = "raw_contact_id";
	public static final String COLUMN_NORMALIZED_NUMBER = "normalized_number";
	public static final String COLUMN_DISPLAY_NAME = "display_name";

}
