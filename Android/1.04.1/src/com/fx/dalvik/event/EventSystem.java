package com.fx.dalvik.event;

import java.util.Date;

import android.content.ContentValues;

import com.fx.dalvik.eventdb.EventDatabaseMetadata;
import com.fx.dalvik.util.GeneralUtil;

public class EventSystem extends Event {
	
	public static final String TYPE = "type_system";
	public static final String EXTRA_TIME = "extra_time";
    public static final String EXTRA_DIRECTION = "extra_direction";
    public static final String EXTRA_DATA = "extra_data";
	
	private long 	time;
	private short 	direction;
	private String 	data;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventSystem(long time, short direction, String data) {
		this.type = Event.TYPE_SYSTEM;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier();
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
			long time, short direction, String data) {
		
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
				this.identifier, this.sendAttempts, 
				GeneralUtil.getDateFormatter().format(new Date(time)), 
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
	
	public long getTime() { 
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
