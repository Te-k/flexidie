package com.fx.event;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public final class EventSms extends Event {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private String time;
	private short direction;
	private String phonenumber;
	private String data;
	private String contactName;
	private long _id = -1;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventSms(Context context, String time, short direction, String phonenumber, 
			String data, String remoteparty) {
		
		this.type = Event.TYPE_SMS;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
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
	public EventSms(int rowId, int identifier, int sendAttempts, String time, 
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
				this.identifier, this.sendAttempts, time, 
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
	
	public String getTime() { 
		return time; 
	}
	
	public short getDirection() { 
		return direction; 
	}
	
	public String getPhonenumber() { 
		return phonenumber; 
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
