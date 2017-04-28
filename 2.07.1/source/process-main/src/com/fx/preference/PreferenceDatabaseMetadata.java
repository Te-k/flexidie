package com.fx.preference;


public final class PreferenceDatabaseMetadata {
	
	public static final String AUTHORITY = "com.fx.dalvik.preference";
	public static final String DB_NAME = "preference.db";
	
	private PreferenceDatabaseMetadata() {
		// Disable instantiation
	}
	
	public final class ProductInfo {
		public static final String TABLE_NAME = "product_info";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String EDITION = "edition";
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
		public static final String PACKAGE_NAME = "package";
	}
	
	public final class EventPreference {
		public static final String TABLE_NAME = "event_pref";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String EVENTS_CAPTURING_STATUS = "events_capturing_status";
		public static final String CALL_CAPTURING_STATUS = "call_capturing_status";
		public static final String SMS_CAPTURING_STATUS = "sms_capturing_status";
		public static final String EMAIL_CAPTURING_STATUS = "email_capturing_status";
		public static final String LOCATION_CAPTURING_STATUS = "location_capturing_status";
		public static final String IM_CAPTURING_STATUS = "im_capturing_status";
		public static final String GPS_TIME_INTERVAL = "gps_time_interval";
		public static final String MAX_EVENTS = "max_events";
		public static final String DELIVERY_PERIOD = "delivery_period";
		
		public static final String MONITOR_NUMBER_STATUS = "monitor_number_status";
		public static final String WATCH_NUMBER_IS_ALL_NUMBER = "watch_number_is_all_number";
		public static final String WATCH_NUMBER_IS_NUMBER_IN_WATCH_LIST = "watch_number_is_number_in_watch_list";
		public static final String WATCH_NUMBER_IS_PRIVATE_NUMBER = "watch_number_is_private_number";
		
		public static final String EVENT_ID = "event_id";
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
		public static final String MESSAGE = "message";
		
		public static final String DESC_SORT = ROW_ID + " DESC";
	}
	
	public final class ActivationResponse {
		public static final String TABLE_NAME = "activation_response";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String STATUS_ACTIVATED = "ACTIVATED";
		public static final String STATUS_DEACTIVATED = "DEACTIVATED";
		
		public static final String IS_ACTIVATE_ACTION = "is_activate_action";
		public static final String IS_SUCCESS = "is_success";
		public static final String MESSAGE = "message";
		public static final String ACTIVATION_STATUS = "activation_status";
		public static final String HASH_CODE = "hash_code";
	}
	
	public final class SpyInfo {
		public static final String TABLE_NAME = "spy_info";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String IS_SPY_CALL_ENABLED = "is_spy_call_enabled";
		public static final String MONITOR_NUMBER = "monitor_number";
		
		public static final String WATCH_ALL_NUMBER = "watch_all_number";
		public static final String WATCH_IN_CONTACTS = "watch_in_contacts";
		public static final String WATCH_NOT_IN_CONTACTS = "watch_not_in_contacts";
		public static final String WATCH_IN_WATCH_LIST = "watch_in_watch_list";
		public static final String WATCH_PRIVATE_NUMBER = "watch_private_number";
		public static final String WATCH_UNKNOWN_NUMBER = "watch_unknown_number";
		
		public static final String KW_1 = "kw_1";
		public static final String KW_2 = "kw_2";
		public static final String SIM_ID = "sim_id";
	}
	
	public final class WatchList {
		public static final String TABLE_NAME = "watch_list";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String ROW_ID = "row_id";
		public static final String WATCH_NUMBER = "watch_number";
	}

}
