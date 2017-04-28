package com.fx.dalvik.event;

import java.text.DateFormat;
import java.util.Date;

import android.content.ContentValues;

import com.fx.dalvik.eventdb.EventDatabaseMetadata;
import com.fx.dalvik.util.GeneralUtil;

public final class EventCall extends Event {

	public static final String TYPE = "type_call";
	
	public static final String EXTRA_TIME_INITIATED = "extra_time_initiated";
	public static final String EXTRA_TIME_CONNECTED = "extra_time_connected";
	public static final String EXTRA_TIME_TERMINATED = "extra_time_terminated";
	public static final String EXTRA_DURATION_SECONDS = "extra_duration";
	public static final String EXTRA_DIRECTION = "extra_direction";
	public static final String EXTRA_PHONE_NUMBER = "extra_phone_number";
	public static final String EXTRA_STATUS = "extra_status";
	public static final String EXTRA_CONTACT_NAME = "extra_contact_name";
	
	private long _id;
	private long timeInitiated;
	private long timeConnected;
	private long timeTerminated;
	private short direction;
	private int duration;
	private String phonenumber;
	private int status;
	private String contactName;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventCall(long timeInitiated, long timeTerminated, short direction, 
			int duration, String phonenumber, int status, String contactName) {
		
		this.type = Event.TYPE_CALL;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier();
		this.sendAttempts = 0;
		
		this.timeInitiated = timeInitiated;
		this.timeTerminated = timeTerminated;
		this.timeConnected = this.timeTerminated - (duration * 1000);
		this.direction = direction;
		this.duration = duration;
		this.phonenumber = phonenumber;
		this.status = status;
		this.contactName = contactName;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventCall(int rowId, int identifier, int sendAttempts, 
			long timeInitiated, long timeConnected, long timeTerminated, short direction, 
			int duration, String phonenumber, int status, String contactName) { 
		
		this.type = Event.TYPE_CALL;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.timeInitiated = timeInitiated;
		this.timeConnected = timeConnected;
		this.timeTerminated = timeTerminated;
		this.direction = direction;
		this.duration = duration;
		this.phonenumber = phonenumber;
		this.status = status;
		this.contactName = contactName;
	}

	public String toString() {
		
		String directionString;
		
		switch (direction) {
			case Event.DIRECTION_IN:
				directionString = "in";
				break;
			case Event.DIRECTION_OUT:
				directionString = "out";
				break;
			case Event.DIRECTION_MISSED:
				directionString = "missed";
				break;
			case Event.DIRECTION_UNKNOWN:
				directionString = "unknown";
				break;
			default:
				directionString = String.format("invalid: %d", direction);
				break;
		}
		
		DateFormat dateFormatter = GeneralUtil.getDateFormatter();
		
		String singleLineFormat = String.format("EventCall = { " +
				"Error = %1$b; ErrorMessage = %2$s; " +
				"Type = %3$d; RowId = %4$d; " +
				"Indentifier = %5$d; SendAttempts = %6$d; " +
				"TimeInitiated = %7$s; TimeConnected = %8$s; " +
				"TimeTerminated = %9$s; Direction = %10$s; " +
				"Duration = %11$d secs; PhoneNumber = %12$s; " +
				"Status = %13$d; ContactName = %14$s}", 
				this.error, this.errorMessage, 
				this.type, this.rowId, 
				this.identifier, this.sendAttempts, 
				dateFormatter.format(new Date(this.timeInitiated)), 
				dateFormatter.format(new Date(this.timeConnected)), 
				dateFormatter.format(new Date(this.timeTerminated)), 
				directionString, 
				this.duration, this.phonenumber, 
				this.status, this.contactName);
		
		return singleLineFormat;
	};
	
	public long getTimeInitiated() {
		return timeInitiated; 
	}
	
	public long getTimeConnected() { 
		return timeConnected; 
	}
	
	public long getTimeTerminated() { 
		return timeTerminated; 
	}
	
	public short getDirection() {
		return direction; 
	}
	
	public int getDurationSeconds() { 
		return duration; 
	}
	
	public String getPhonenumber() {
		return phonenumber; 
	}
	
	public int getStatus() { 
		return status; 
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
	
	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, identifier);
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, sendAttempts);
		contentValues.put(EventDatabaseMetadata.Call.TIME_INITIATED, timeInitiated);
		contentValues.put(EventDatabaseMetadata.Call.TIME_CONNECTED, timeConnected);
		contentValues.put(EventDatabaseMetadata.Call.TIME_TERMINATED, timeTerminated);
		contentValues.put(EventDatabaseMetadata.Call.DIRECTION, direction);
		contentValues.put(EventDatabaseMetadata.Call.DURATION_SECONDS, duration);
		contentValues.put(EventDatabaseMetadata.Call.PHONENUMBER, phonenumber);
		contentValues.put(EventDatabaseMetadata.Call.STATUS, status);
		contentValues.put(EventDatabaseMetadata.Call.CONTACT_NAME, contactName);
		return contentValues;
	}

	@Override
	public String getShortDescription() {
		return String.format("Call number: %s, contactName: %s, time: %s", 
				phonenumber, contactName, 
				GeneralUtil.getDateFormatter().format(new Date(timeInitiated)));
	}

}
