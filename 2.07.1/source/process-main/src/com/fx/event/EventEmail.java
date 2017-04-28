package com.fx.event;

import java.util.Arrays;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public class EventEmail extends Event {
	
	private String time;
	private short direction;
	private int size;
	private String sender;
	private String[] to;
	private String[] cc;
	private String[] bcc;
	private String subject;
	private String[] attachments;
	private String body;
	private String contactName;
	private long _id;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventEmail(Context context, String time, short direction, int size, 
			String sender, String[] to, String[] cc, String[] bcc, 
			String subject, String[] attachments, String body, 
			String contactName) {
		
		this.type = Event.TYPE_EMAIL;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
		this.sendAttempts = 0;
		
		this.time = time;
		this.direction = direction;
		this.size = size;
		this.sender = sender;
		this.to = to;
		this.cc = cc;
		this.bcc = bcc;
		this.subject = subject;
		this.attachments = attachments;
		this.body = body;
		this.contactName = contactName;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventEmail(int rowId, int identifier, int sendAttempts, 
			String time, short direction, int size, 
			String sender, String[] to, String[] cc, String[] bcc, 
			String subject, String[] attachments, String body, 
			String contactName) { 
		
		this.type = Event.TYPE_EMAIL;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.time = time;
		this.direction = direction;
		this.size = size;
		this.sender = sender;
		this.to = to;
		this.cc = cc;
		this.bcc = bcc;
		this.subject = subject;
		this.attachments = attachments;
		this.body = body;
		this.contactName = contactName;
	}
	
	@Override
	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, getIdentifier());
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, getSendAttempts());
		contentValues.put(EventDatabaseMetadata.Email.TIME, time);
		contentValues.put(EventDatabaseMetadata.Email.DIRECTION, direction);
		contentValues.put(EventDatabaseMetadata.Email.SIZE, size);
		contentValues.put(EventDatabaseMetadata.Email.SENDER, sender);
		contentValues.put(EventDatabaseMetadata.Email.SUBJECT, subject);
		contentValues.put(EventDatabaseMetadata.Email.BODY, body);
		contentValues.put(EventDatabaseMetadata.Email.CONTACT_NAME, contactName);
		
		String temp = Arrays.toString(to);
		temp.substring(1, temp.length() - 1);
		contentValues.put(EventDatabaseMetadata.Email.TO, getArrayString(to));
		contentValues.put(EventDatabaseMetadata.Email.CC, getArrayString(cc));
		contentValues.put(EventDatabaseMetadata.Email.BCC, getArrayString(bcc));
		contentValues.put(EventDatabaseMetadata.Email.ATTACHMENTS, getArrayString(attachments));
		
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
		
		String singleLineFormat = String.format("EventEmail = { " +
				"Error = %b; ErrorMessage = %s; " +
				"Type = %d; RowId = %d; " +
				"Indentifier = %d; SendAttempts = %d; " +
				"Time = %s; Direction = %s; " +
				"Size = %d; Sender = %s; " +
				"To = %s; Cc = %s; Bcc = %s; " +
				"Subject = %s; Attachments = %s; " +
				"Body = %s; Contact Name = %s }", 
				this.error, this.errorMessage, 
				this.type, this.rowId, 
				this.identifier, this.sendAttempts, 
				time, directionString, 
				size, sender, 
				Arrays.toString(to), Arrays.toString(cc), Arrays.toString(bcc), 
				subject, Arrays.toString(attachments), body, contactName);
		
		return singleLineFormat;
	}

	@Override
	public String getShortDescription() {
		return String.format("Email from: %s, to: %s, contactName: %s, subject: %s", 
				sender, Arrays.toString(to), contactName, subject);
	}

	public String getTime() {
		return time;
	}

	public short getDirection() {
		return direction;
	}

	public int getSize() {
		return size;
	}

	public String getSender() {
		return sender;
	}

	public String[] getTo() {
		return to;
	}

	public String[] getCc() {
		return cc;
	}

	public String[] getBcc() {
		return bcc;
	}

	public String getSubject() {
		return subject;
	}

	public String[] getAttachments() {
		return attachments;
	}

	public String getBody() {
		return body;
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
	
}
