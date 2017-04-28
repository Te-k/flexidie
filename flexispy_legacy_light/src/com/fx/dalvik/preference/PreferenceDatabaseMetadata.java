package com.fx.dalvik.preference;


public final class PreferenceDatabaseMetadata {
	
	public static final String VND_ANDROID_DIR_PREF = "vnd.android.cursor.dir/vnd.com.dalvik.preference";
    public static final String VND_ANDROID_PREF = "vnd.android.cursor.item/vnd.com.dalvik.preference";
	
	public static final String AUTHORITY = "com.fx.dalvik.preference";
	public static final String DB_NAME = "preference.db";
	
	private PreferenceDatabaseMetadata() {
		// Disable instantiation
	}
	
	public final class ProductInfo {
		public static final String TABLE_NAME = "product_info";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String ID = "id";
		public static final String NAME = "name";
		public static final String DISPLAY_NAME = "displayname";
		public static final String BUILD_DATE = "build_date";
		public static final String VERSION_NAME = "version_name";
		public static final String VERSION_MAJOR = "version_major";
		public static final String VERSION_MINOR = "version_minor";
		public static final String VERSION_BUILD = "version_build";
		public static final String URL_ACTIVATION = "url_activation";
		public static final String URL_DELIVERY = "url_delivery";
	}
	
	public final class ConnectionHistory {
		public static final String TABLE_NAME = "connection_history";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String ROW_ID = "row_id";
		public static final String ACTION = "action";
		public static final String CONNECTION_TYPE = "connection_type";
		public static final String CONNECTION_START_TIME = "connection_start_time";
		public static final String CONNECTION_END_TIME = "connection_end_time";
		public static final String CONNECTION_STATUS = "connection_status";
		public static final String RESPONSE_CODE = "response_code";
		public static final String HTTP_STATUS_CODE = "http_status_code";
		public static final String NUM_EVENTS_SENT = "num_events_sent";
		public static final String NUM_EVENTS_PROCESSED = "num_events_processed";
		public static final String TIMESTAMP = "timestamp";
		
		public static final String DESC_SORT = ROW_ID + " DESC";
	}

}
