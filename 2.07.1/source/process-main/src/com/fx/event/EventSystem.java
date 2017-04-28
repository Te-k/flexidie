package com.fx.event;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public class EventSystem extends Event {
	
//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private String time;
	private short direction;
	private String data;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventSystem(Context context, String time, short direction, String data) {
		this.type = Event.TYPE_SYSTEM;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
		this.sendAttempts = 0;
		
		this.time = time;
		this.direction = direction;
		this.data = data;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventSystem(int rowId, int identifier, int sendAttempts, 
			String time, short direction, String data) {
		
		this.type = Event.TYPE_SYSTEM;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.time = time;
		this.direction = direction;
		this.data = data;
	}
	
	public String toString() {
		String singleLineFormat = String.format("EventSystem = { " +
				"Error = %1$b; ErrorMessage = %2$s; " +
				"Type = %3$d; RowId = %4$d; " +
				"Indentifier = %5$d; SendAttempts = %6$d; " +
				"Time = %7$s; Direction = %8$d; Data = %9$s; }", 
				this.error, this.errorMessage, 
				this.type, this.rowId, 
				this.identifier, this.sendAttempts, time, 
				this.direction, this.data.replace("\n", ""));
		
		return singleLineFormat;
	}
	
	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, identifier);
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, sendAttempts);
		contentValues.put(EventDatabaseMetadata.System.TIME, time);
		contentValues.put(EventDatabaseMetadata.System.DIRECTION, direction);
		contentValues.put(EventDatabaseMetadata.System.DATA, data);
		return contentValues;
	}
	
	public String getTime() { 
		return this.time; 
	}
	
	public short getDirection() { 
		return this.direction;
	}
	
	public String getData() { 
		return this.data; 
	}

	@Override
	public String getShortDescription() {
		return String.format("System data: %s, time: %s", data, time);
	}

}
