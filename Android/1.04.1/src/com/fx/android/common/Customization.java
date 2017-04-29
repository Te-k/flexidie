package com.fx.android.common;

public class Customization {
	
	public static boolean DEBUG = true;
	
	/**
	 * DEFAULT SETTINGS FOR CONNECTION HISTORY
	 */
	public static int getMaxConnectionHistory() {
		return 5;
	}
	
	/**
	 * DEFAULT SETTINGS FOR HTTP CONNECTION
	 */
	public static long getDefaultURLRequestTimeoutShort() {
		return 60;
	}
	
	public static long getDefaultURLRequestTimeoutLong() {
		return 300;
	}

}
