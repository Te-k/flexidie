package com.fx.event;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public final class EventCall extends Event {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private String timeInitiated;
	private String timeConnected;
	private String timeTerminated;
	private short direction;
	private int duration;
	private String phonenumber;
	private int status;
	private String contactName;
	private long _id = -1;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventCall(Context context, 
			String timeInitiated, String timeTerminated, String timeConnected, 
			short direction, int duration, String phonenumber, int status, String contactName) {
		
		this.type = Event.TYPE_CALL;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
		this.sendAttempts = 0;
		
		this.timeInitiated = timeInitiated;
		this.timeTerminated = timeTerminated;
		this.timeConnected = timeConnected;
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
			String timeInitiated, String timeConnected, String timeTerminated, 
			short direction, int duration, String phonenumber, int status, String contactName) { 
		
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
				this.timeInitiated, 
				this.timeConnected, 
				this.timeTerminated, 
				directionString, 
				this.duration, this.phonenumber, 
				this.status, this.contactName);
		
		return singleLineFormat;
	};
	
	public String getTimeInitiated() {
		return timeInitiated; 
	}
	
	public String getTimeConnected() { 
		return timeConnected; 
	}
	
	public String getTimeTerminated() { 
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
				phonenumber, contactName, timeInitiated);
	}

}
