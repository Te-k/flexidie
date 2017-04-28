package com.fx.dalvik.event;

import java.util.Date;

import android.content.ContentValues;

import com.fx.dalvik.eventdb.EventDatabaseMetadata;
import com.fx.dalvik.util.GeneralUtil;

public final class EventSms extends Event {
	
	public static final String TYPE = "type_sms";
	
 	public static final String EXTRA_TIME = "extra_time";
 	public static final String EXTRA_DIRECTION = "extra_direction";
	public static final String EXTRA_PHONE_NUMBER = "extra_phone_number";
	public static final String EXTRA_DATA = "extra_message_body";
    public static final String EXTRA_CONTACT_NAME = "extra_contact_name";

	private long _id;
	private long time;
	private short direction;
	private String phonenumber;
	private String data;
	private String contactName;
	
	public EventSms() {
		
	}
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventSms(long time, short direction, String phonenumber, 
			String data, String remoteparty) {
		
		this.type = Event.TYPE_SMS;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier();
		this.sendAttempts = 0;
		
		this.time = time;
		this.direction = direction;
		this.phonenumber = phonenumber;
		this.data = data;
		this.contactName = remoteparty;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventSms(int rowId, int identifier, int sendAttempts, long time, 
			short direction, String phonenumber, String data, String remoteparty) { 
		
		this.type = Event.TYPE_SMS;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.time = time;
		this.direction = direction;
		this.phonenumber = phonenumber;
		this.data = data;
		this.contactName = remoteparty;
	}

	public String toString() {
		
		String singleLineFormat = String.format("EventSMS = { " +
				"Error = %1$b; ErrorMessage = %2$s; " +
				"Type = %3$d; RowId = %4$d; " +
				"Indentifier = %5$d; SendAttempts = %6$d; " +
				"Time = %7$s; Direction = %8$d; " +
				"Phonenumber = %9$s; Data = %10$s; " +
				"Remoteparty = %11$s }", 
				this.error, this.errorMessage, 
				this.type, this.rowId, 
				this.identifier, this.sendAttempts, 
				GeneralUtil.getDateFormatter().format(new Date(time)), 
				this.direction, 
				this.phonenumber, this.data.replace("\n", ""), 
				this.contactName);
		
		return singleLineFormat;
	};

	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, getIdentifier());
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, getSendAttempts());
		contentValues.put(EventDatabaseMetadata.Sms.TIME, getTime());
		contentValues.put(EventDatabaseMetadata.Sms.DIRECTION, getDirection());
		contentValues.put(EventDatabaseMetadata.Sms.PHONENUMBER, getPhonenumber());
		contentValues.put(EventDatabaseMetadata.Sms.DATA, getData());
		contentValues.put(EventDatabaseMetadata.Sms.CONTACT_NAME, getContactName());
		return contentValues;
	}
	
	public long getTime() { 
		return time; 
	}
	
	public short getDirection() { 
		return direction; 
	}
	
	public void setPhoneNumber(String number) {
		this.phonenumber = number;
	}
	
	public String getPhonenumber() { 
		return phonenumber; 
	}
	
	public void setDate(String data) {
		this.data = data;
	}
	
	public String getData() { 
		return data; 
	}
	
	public String getContactName() { 
		return contactName; 
	}
	
	public void setId(long id) {
		_id = id;
	}
	
	public long getId() {
		return _id;
	}

	@Override
	public String getShortDescription() {
		return String.format("SMS number: %s, contactName: %s, msg: %s, time: %s", 
				phonenumber, contactName, data, time);
	}
	
}
