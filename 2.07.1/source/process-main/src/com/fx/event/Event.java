package com.fx.event;

import android.content.ContentValues;
import android.content.Context;

import com.fx.preference.PreferenceManager;

public abstract class Event { 
	
	public static final short TYPE_CALL = 0;
	public static final short TYPE_SMS = 1;
	public static final short TYPE_EMAIL = 2;
	public static final short TYPE_LOCATION = 3;
	public static final short TYPE_IM = 16;
	public static final short TYPE_SYSTEM = 127;
	
	// Email is not yet supported
	public static final short[] TYPES_LIST = { 
		TYPE_CALL, TYPE_SMS, TYPE_EMAIL, 
		TYPE_LOCATION, TYPE_IM, TYPE_SYSTEM 
		};

	public static final short ROWID_UNKNOWN = -1;
	public static final short IDENTIFIER_UNKNOWN = -1;
	public static final short DURATION_UNKNOWN = -1;
	public static final short TIME_UNKNOWN = 0;

	public static final short DIRECTION_UNKNOWN = -1;
	public static final short DIRECTION_IN = 1;
	public static final short DIRECTION_OUT = 2;
	public static final short DIRECTION_MISSED = 3;

	public static final short STATUS_UNKNOWN = -1;
	public static final short STATUS_INCOMING = 1;
	public static final short STATUS_OUTGOING = 2;
	public static final short STATUS_INPROGRESS = 3;
	public static final short STATUS_ONHOLD = 4;
	public static final short STATUS_TERMINATED = 5;
	
	public static final String IM_WHATSAPP = "WhatsApp";
	public static final String IM_GTALK = "Google Talk";
	public static final String IM_FACEBOOK = "Facebook";
	public static final String IM_SKYPE = "Skype";

	public static final String REMOTEPARTY_UNKNOWN = "";
	
	public static String getTypeAsString(short eventType) {
		String typeName = null;
		switch (eventType) {
			case Event.TYPE_CALL:
				typeName = "TYPE_CALL";
				break;
			case Event.TYPE_SMS:
				typeName = "TYPE_SMS";
				break;
			case Event.TYPE_EMAIL:
				typeName = "TYPE_EMAIL";
				break;
			case Event.TYPE_LOCATION:
				typeName = "TYPE_LOCATION";
				break;
			case Event.TYPE_IM:
				typeName = "TYPE_IM";
				break;
			case Event.TYPE_SYSTEM:
				typeName = "TYPE_SYSTEM";
				break;
		}
		return typeName;
	}
	
	protected boolean error;
	protected String errorMessage;
	protected short type;
	protected int rowId;
	protected int identifier;
	protected int sendAttempts;
	
	protected int generateIdentifier(Context context) {
		try {
			PreferenceManager prefManager = PreferenceManager.getInstance(context);
			int currentId = prefManager.getEventId();
			prefManager.setEventId(currentId + 1);
			return currentId;
		}
		catch (Exception e) {
			// Do nothing
		}
		return (int) ((System.currentTimeMillis() / 1000) & 0x7fffffff);
	}
	
	public boolean getError() {
		return error;
	}
	
	public String getErrorMessage() {
		return errorMessage;
	}
	
	public short getType() {
		return type;
	}
	
	public int getRowId() {
		return rowId;
	}
	
	public int getIdentifier() {
		return identifier;
	}
	
	public int getSendAttempts() {
		return sendAttempts;
	}
	
	public void setSendAttempts(int sendAttempts) {
		this.sendAttempts = sendAttempts; 
	}
	
	public abstract ContentValues getContentValues();
	
	public abstract String getShortDescription();
}
