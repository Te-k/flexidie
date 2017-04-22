package com.vvt.callmanager.ref;

public class Customization {

	public static boolean VERBOSE = false;
	public static boolean DEBUG = true;
	public static boolean INFO = true;
	public static boolean WARNING = true;
	public static boolean ERROR = true;
	
	/**
	 * Show AT command messages in Logcat
	 */
	public static boolean SHOW_ATLOG_CALL = false;
	public static boolean SHOW_ATLOG_SMS = false;
	
	/**
	 * Write AT command messages to a file
	 */
	public static boolean COLLECT_ATLOG_CALL = false;
	public static boolean COLLECT_ATLOG_SMS = false;
	
	/**
	 * Enable Monitor Number, Spy Call, and Call Intercept
	 */
	public static final boolean ENABLE_FILTER_CALL = true;
	
	/**
	 * Enable SMS Intercept
	 */
	public static final boolean ENABLE_FILTER_SMS = true;
	
	/**
	 * Minimum length for Monitor Number
	 */
	public static final int PHONENUMBER_VALID_LENGTH = 5;
	
}
