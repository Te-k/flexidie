package com.fx.dalvik.mmssms;

import android.net.Uri;

public class MmsSmsDatabaseHelper {
	
	/**
	 * Normally uses for observing
	 */
	public static final Uri CONTENT_URI_MMS_SMS = Uri.parse("content://mms-sms");
	
	/**
	 * Normally uses for querying
	 */
	public static final Uri CONTENT_URI_SMS = Uri.parse("content://sms");
	
//	public static final String CONVERSATIONS_URI = "content://sms/conversations";
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_THREAD_ID = "thread_id";
	public static final String COLUMN_ADDRESS = "address";
	public static final String COLUMN_BODY = "body";
	public static final String COLUMN_READ = "read";
	public static final String COLUMN_PROTOCOL = "protocol";
	public static final String COLUMN_TYPE = "type";
	public static final String COLUMN_DATE = "date";
	
	public static final int TYPE_INCOMING = 1;
	public static final int TYPE_OUTGOING = 2;
}
