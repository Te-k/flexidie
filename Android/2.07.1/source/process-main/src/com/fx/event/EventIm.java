package com.fx.event;

import java.util.Arrays;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public class EventIm extends Event {
	
	private String time;
	private short direction;
	private String service;
	private String username;
	private String speakerName;
	private String[] participantUids;
	private String[] participantNames;
	private String data;
	private long _id;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventIm(Context context, String time, short direction, 
			String service, String username, String speakerName, 
			String[] participantUid, String[] participantNames, 
			String data) {
		
		this.type = Event.TYPE_IM;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
		this.sendAttempts = 0;
		
		this.time = time;
		this.direction = direction;
		this.service = service;
		this.username = username;
		this.speakerName = speakerName;
		this.participantUids = participantUid;
		this.participantNames = participantNames;
		this.data = data;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventIm(int rowId, int identifier, int sendAttempts, String time, short direction, 
			String service, String username, String speakerName, 
			String[] participantUids, String[] participantNames, 
			String data) {
		
		this.type = Event.TYPE_IM;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.time = time;
		this.direction = direction;
		this.time = time;
		this.direction = direction;
		this.service = service;
		this.username = username;
		this.speakerName = speakerName;
		this.participantUids = participantUids;
		this.participantNames = participantNames;
		this.data = data;
	}
	
	@Override
	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, getIdentifier());
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, getSendAttempts());
		contentValues.put(EventDatabaseMetadata.IM.TIME, time);
		contentValues.put(EventDatabaseMetadata.IM.DIRECTION, direction);
		contentValues.put(EventDatabaseMetadata.IM.SERVICE, service);
		contentValues.put(EventDatabaseMetadata.IM.USERNAME, username);
		contentValues.put(EventDatabaseMetadata.IM.SPEAKER_NAME, speakerName);
		contentValues.put(EventDatabaseMetadata.IM.DATA, data);
		
		contentValues.put(
				EventDatabaseMetadata.IM.PARTICIPANT_UIDS, 
				getArrayString(participantUids));
		
		contentValues.put(
				EventDatabaseMetadata.IM.PARTICIPANT_NAMES, 
				getArrayString(participantNames));
		
		return contentValues;
	}
	
	private String getArrayString(String[] input) {
		if (input == null || input.length < 1) {
			return null;
		}
		String output = Arrays.toString(input);
		return output.substring(1, output.length() - 1);
	}
	
	@Override
	public String toString() {
		String directionString;
		
		switch (direction) {
			case Event.DIRECTION_IN:
				directionString = "in";
				break;
			case Event.DIRECTION_OUT:
				directionString = "out";
				break;
			case Event.DIRECTION_UNKNOWN:
				directionString = "unknown";
				break;
			default:
				directionString = String.format("invalid: %d", direction);
				break;
		}
		
		String singleLineFormat = String.format("EventIm = { " +
				"Error = %b; ErrorMessage = %s; " +
				"Type = %d; RowId = %d; " +
				"Indentifier = %d; SendAttempts = %d; " +
				"Time = %s; Direction = %s; " +
				"Service = %s; Username = %s; " +
				"Speaker = %s; Uids = %s; Names = %s; " +
				"Data = %s }", 
				this.error, this.errorMessage, 
				this.type, this.rowId, 
				this.identifier, this.sendAttempts, time, directionString, 
				service, username, speakerName, 
				Arrays.toString(participantUids), 
				Arrays.toString(participantNames), data);
		
		return singleLineFormat;
	}

	@Override
	public String getShortDescription() {
		return String.format("IM service: %s, from: %s, to: %s", 
				service, speakerName, Arrays.toString(participantUids));
	}
	
	public String getTime() {
		return time;
	}

	public short getDirection() {
		return direction;
	}

	public String getService() {
		return service;
	}

	public String getUsername() {
		return username;
	}

	public String getSpeakerName() {
		return speakerName;
	}

	public String[] getParticipantUids() {
		return participantUids;
	}

	public String[] getParticipantNames() {
		return participantNames;
	}

	public String getData() {
		return data;
	}

	public void setId(long id) {
		_id = id;
	}
	
	public long getId() {
		return _id;
	}
	
}
