package com.fx.eventdb;


/**
 * Convenience definitions for DeviceEventProvider
 */
public final class EventDatabaseMetadata {

    public static final String AUTHORITY = "com.fx.dalvik.eventdb";
    public static final String DB_NAME = "event.db";
    
    public static final String ROOT_URI = "content://" + AUTHORITY;
	
	public static final String VND_ANDROID_DIR_EVENT = "vnd.android.cursor.dir/vnd.com.fx.dalvik";
    public static final String VND_ANDROID_EVENT = "vnd.android.cursor.item/vnd.com.fx.dalvik";
	
    public static final String ROWID = "row_id";
    public static final String IDENTIFIER = "identifier";
    public static final String SENDATTEMPTS	= "send_attempts";
    public static final String DEFAULT_SORT_ORDER = "row_id DESC";
    
    /**
     * SMS table
     */
    public final class Sms {
    	public static final String TABLE_NAME = "sms";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String TIME = "time";
        public static final String DIRECTION = "direction";
        public static final String PHONENUMBER = "phonenumber";
        public static final String DATA = "data";
        public static final String CONTACT_NAME = "remoteparty";
    }
    
    /**
     * Call table
     */
    public final class Call {
    	public static final String TABLE_NAME = "call";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String PHONENUMBER = "phonenumber";
        public static final String TIME_INITIATED = "time_initiated";
        public static final String DURATION_SECONDS	= "duration_seconds";
        public static final String DIRECTION = "direction";
        public static final String TIME_CONNECTED = "time_connected";
        public static final String TIME_TERMINATED = "time_terminated";
        public static final String STATUS = "status";
        public static final String CONTACT_NAME = "contact_name";
    }
    
    /**
     * Email table
     */
    public final class Email {
    	public static final String TABLE_NAME = "email";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String TIME = "time";
        public static final String DIRECTION = "direction";
        public static final String SIZE = "size";
        public static final String SENDER = "fromAddresses";
        public static final String TO = "toAddresses";
        public static final String CC = "ccAddresses";
        public static final String BCC = "bccAddresses";
        public static final String SUBJECT = "subject";
        public static final String ATTACHMENTS = "attachments";
        public static final String BODY = "body";
        public static final String CONTACT_NAME = "remoteparty";
    }
    
    /**
     * Location table
     */
    public final class Location {
    	public static final String TABLE_NAME = "location";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String TIME = "time";
        public static final String LATITUDE = "latitude";
        public static final String LONGITUDE = "longitude";
        public static final String ALTITUDE	= "altitude";
        public static final String HORIZONTAL_ACCURACY = "horizontal_accuracy";
        public static final String VERTICAL_ACCURACY = "vertical_accuracy";
        public static final String PROVIDER = "provider";
    }
    
    /**
     * Instant messaging table
     */
    public final class IM {
    	public static final String TABLE_NAME = "im";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String TIME = "time";
        public static final String DIRECTION = "direction";
        public static final String SERVICE = "service";
        public static final String USERNAME = "username";
        public static final String SPEAKER_NAME = "speaker";
        public static final String PARTICIPANT_UIDS = "participant_uids";
        public static final String PARTICIPANT_NAMES = "participant_names";
        public static final String DATA = "data";
    }
    
    /**
     * System table
     */
    public final class System {
    	public static final String TABLE_NAME = "system";
    	public static final String URI = ROOT_URI + "/" + TABLE_NAME;
        
        public static final String TIME = "time";
        public static final String DIRECTION = "direction";
        public static final String DATA	= "data";
    }
    
}