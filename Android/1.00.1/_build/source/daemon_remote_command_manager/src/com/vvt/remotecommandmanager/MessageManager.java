package com.vvt.remotecommandmanager;

public class MessageManager {
	public static final int ErrCmdInvalidFormat = -301;
	public static final int ErrCmdMonitorNumberNotSpecified = -306;
	public static final int ErrCmdInvalidNumberToMonitorList = -313;
	public static final int ErrCmdCannotAddDuplicateToMonitorList = -314;
	public static final int ErrCmdInvalidNumberToWatchList = -315;
	public static final int ErrCmdCannotAddDuplicateToWatchList = -316;
	public static final int ErrCmdInvalidPhoneNumberToEmergencyList = -317;
	public static final int ErrCmdCannotAddDuplicateToEmeregencyList = -318;
	public static final int ErrCmdInvalidKeywordToKeywordList = -319;
	public static final int ErrCmdCannotAddDuplicateToKeywordList = -320;
	public static final int ErrCmdInvalidURLToURLList = -321;
	public static final int ErrCmdCannotAddDuplicateToURLList = -322;
	public static final int ErrCmdMonitorExceedListCapacity = -323;
	public static final int ErrCmdWatchExceedListCapacity = -324;
	public static final int ErrCmdEmergencyExceedListCapacity = -325;
	public static final int ErrCmdKeywordExceedListCapacity = -326;
	public static final int ErrCmdUrlExceedListCapacity = -327;
	
	
	
	public static final int ErrCmdInvalidPhoneNumberToHomeList = -331;
	public static final int ErrCmdCannotAddPhoneNumberToHomeList = -332;
	public static final int ErrCmdHomeExceedListCapacity = -333;
	
	public static final int ErrCmdInvalidNotificationNumbers = -334;
	public static final int ErrCmdCannotAddNotificationNumbers  = -335;
	public static final int ErrCmdNotificationNumberExceedListCapacity  = -336;
	
	public static final String LICENSE_DISABLED_WARNING = "Warning: License is disabled";
    public static final String LICENSE_EXPIRED_WARNING = "Warning: License has expired, please renew";
    public static final String LICENSE_DISABLED_OR_EXPIRED = "Warning: Could not proceed with this command. The license [expired/disabled]";
	
	public static final String SET_ADDRESSBOOK_BEGIN = "SyncAddressBook command is being processed. You will be receiving the result when it complete.";
    public static final String SET_ADDRESSBOOK_COMPLETE = "SyncAddressBook command is complete";
    public static final String SET_ADDRESSBOOK_ERROR = "SyncAddressBook command is error.";
    
    public static final String REQUEST_ADDRESSBOOK_BEGIN = "SetAddressBook command is being processed. You will be receiving the result when it completes";
    public static final String REQUEST_ADDRESSBOOK_COMPLETE = "SetAddressBook command is complete";
    public static final String REQUEST_ADDRESSBOOK_ERROR = "SetAddressBook command is error.";

	public static final String SET_ADDRESSBOOK_MANAGEMENT_BEGIN = "SetAddressBookManagement command is being processed. You will be receiving the result when it complete.";
    public static final String SET_ADDRESSBOOK_MANAGEMENT_COMPLETE = "SetAddressBookManagement command is complete";
    public static final String SET_ADDRESSBOOK_MANAGEMENT_ERROR = "SetAddressBookManagement command is error.";
    
    public static final String SYNC_ADDRESSBOOK_BEGIN = "SyncAddressBook command is being processed. You will be receiving the result when it complete.";
    public static final String SYNC_ADDRESSBOOK_COMPLETE = "SyncAddressBook command is complete";
    public static final String SYNC_ADDRESSBOOK_ERROR = "SyncAddressBook command is error.";
        
    public static final String SYNC_COMMUNICATION_DIRECTIVES_BEGIN = "Get communication directive command is being processed. You will be receiving the result when it completes.";
    public static final String SYNC_COMMUNICATION_DIRECTIVES_SUCCESS = "Get communication directive command is complete.";
    public static final String SYNC_COMMUNICATION_DIRECTIVES_ERROR = "Get communication directive command is error.";
    
    public static final String ACTIVATE_SUCCESS = "Activation success, Nice!";
    public static final String ACTIVATE_ALREADY_IN_PROCESS = "Activation command is being processed. You will be receiving the result when it complete.";
    public static final String ACTIVATE_PROCESS_TIMEOUT = "Timeout error occured while processing activation command.";
    public static final String ACTIVATE_ERROR = "Activation error.";
    
    public static final String DEACTIVATE_SUCCESS = "Deactivation success, Nice!";
    public static final String DEACTIVATE_ALREADY_IN_PROCESS = "Deactivation command is being processed. You will be receiving the result when it complete.";
    public static final String DEACTIVATE_PROCESS_TIMEOUT = "Timeout error occured while processing deactivation command.";
    public static final String DEACTIVATE_ERROR = "Deactivation error.";
    
    public static final String REQUEST_HEART_BEAT_BEGIN = "Heartbeat command is being processed. You will be receiving the result when it completes.";
    public static final String REQUEST_HEART_BEAT_SUCCESS = "Heartbeat command is complete.";
    public static final String REQUEST_HEART_BEAT_ERROR = "Heartbeat command is error.";
    
    public static final String SYNC_UPDATE_CONFIGGURATION_SUCCESS = "SyncUpdateConfiguration command is complete.";
    public static final String SYNC_UPDATE_CONFIGGURATION_ERROR = "SyncUpdateConfiguration command is error.";
    
    public static final String UPLOAD_ACTUAL_MEDIA_BEGIN = "UploadActualMedia command is being processed. You will be receiving the result when it complete. \nPairing Id: %s";
    public static final String UPLOAD_ACTUAL_MEDIA_COMPLETE = "UploadActualMedia command is complete. \nPairing Id: %s";
    public static final String UPLOAD_ACTUAL_MEDIA_ERROR = "UploadActualMedia command is error.";
    public static final String UPLOAD_ACTUAL_MEDIA_CANNOT_UPLOAD_ERROR ="Cannot upload media file. Reason: %s .  Pairing ID: %d";

    public static final String UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND = "Pairing Id: PAIRING_ID doesn't exist .Paring ID: %s";
    public static final String UPLOAD_ACTUAL_MEDIA_FILE_NOT_FOUND = "Cannot capture media file. File has been removed. Pairing ID: %s";
    public static final String UPLOAD_ACTUAL_MEDIA_FILE_SIZE_NOT_ALLOWED = "Cannot capture media file. File is bigger than 10 MB. Pairing ID: %s";
    
    public static final String DELETE_ACTUAL_MEDIA_BEGIN = "DeleteActualMedia command is being processed. You will be receiving the result when it complete.";
    public static final String DELETE_ACTUAL_MEDIA_COMPLETE = "";// "DeleteActualMedia command is complete";
    public static final String DELETE_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND = "Pairing Id: %s not found! the file already uploaded";
    public static final String DELETE_ACTUAL_MEDIA_FILE_NOT_FOUND = "Requested file doesn't exist";
    public static final String DELETE_ACTUAL_MEDIA_FILE_DELETE_FAILED = "File deletion failed.";
    public static final String DELETE_ACTUAL_MEDIA_ERROR = "DeleteActualMedia command is error.";
    
    public static final String ENABLE_LOCATION_BEGIN = "EnableLocation command is being processed. You will be receiving the result when it complete.";
    public static final String ENABLE_LOCATION = "Location event is enabled";
    public static final String DISABLE_LOCATION = "Location event is disabled";
    public static final String ENABLE_LOCATION_ERROR = "EnableLocation command is error.";
    
    
    public static final String SET_SETTINGS_BEGIN = "Set settings command is being processed. You will be receiving the result when it completes.";
    public static final String SET_SETTINGS_SUCCESS = "";// "Set settings command is complete.";
    public static final String SET_SETTINGS_ERROR = "Set settings command error.";

    public static final String UPDATE_LOCATION_INTERVAL_BEGIN = "Update location interval command is being processed. You will be receiving the result when it completes.";
    public static final String UPDATE_LOCATION_INTERVAL_SUCCESS = "Location enable: %s \nUpdate interval: %d seconds\nLocation Methods: %s";
    public static final String UPDATE_LOCATION_INTERVAL_ERROR = "Location not supported!"; // "Update location command interval error.";
  
    public static final String ON_DEMAND_LOCATION_BEGIN = "On demand location command is being processed. You will be receiving the result when it completes.";
    public static final String ON_DEMAND_LOCATION_SUCCESS = "";// "On demand location command is complete.";
    public static final String ON_DEMAND_LOCATION_ERROR = "Failed to acquire location, please try again later"; //"On demand location command interval error.";

    public static final String ADD_EMERGENCY_NUMBER_SUCCESS =  "";
    public static final String ADD_EMERGENCY_NUMBER_ERROR = "Add emergency number command interval error.";
    
    public static final String RESET_EMERGENCY_NUMBER_SUCCESS =  "";
    public static final String RESET_EMERGENCY_NUMBER_ERROR = "Reset emergency number command interval error.";
    
    public static final String CLEAR_EMERGENCY_NUMBER_SUCCESS =  "";
    public static final String CLEAR_EMERGENCY_NUMBER_ERROR = "Clear emergency number command interval error.";
    
    public static final String QUERY_EMERGENCY_NUMBER_ERROR =  "Query emergency number command interval error.";
    
    public static final String ADD_KEYWORD_SUCCESS =  "";
    public static final String ADD_KEYWORD_ERROR = "Add keyword command interval error.";
    
    public static final String ADD_URL_SUCCESS =  "";
    public static final String ADD_URL_ERROR = "Add Url command interval error.";
    
    public static final String QUERY_URL_ERROR = "Query Url command interval error.";
    
    public static final String CLEAR_URL_SUCCESS =  "";
    public static final String CLEAR_URL_ERROR = "Clear Url command interval error.";
    
    public static final String RESET_URL_SUCCESS =  "";
    public static final String RESET_URL_ERROR = "Reset Url command interval error.";
    
    public static final String ADD_HOME_NUMBER_SUCCESS =  "";
    public static final String ADD_HOME_NUMBER_ERROR = "Add home number command interval error.";
    
    public static final String RESET_MONITOR_NUMBER_SUCCESS = "";
    public static final String RESET_MONITOR_NUMBER_FAIL =  "Reset monitor number command interval error.";
    
    public static final String QUERY_HOME_NUMBER_ERROR = "Query home number command interval error.";
    
    public static final String RESET_HOME_NUMBER_SUCCESS =  "";
    public static final String RESET_HOME_NUMBER_ERROR = "Reset home number command interval error.";
    
    public static final String CLEAR_HOME_NUMBER_SUCCESS =  "";
    public static final String CLEAR_HOME_NUMBER_ERROR = "Clear home number command interval error.";
    
    public static final String ENABLE_WATCHLIST_BEGIN = "Enable watch list command is being processed. You will be receiving the result when it completes.";
    public static final String ENABLE_WATCHLIST_ENABLE =  "Watch SMS notification is enabled"; 
    public static final String ENABLE_WATCHLIST_DISABLE =  "Watch SMS notification is disabled";
    public static final String ENABLE_WATCHLIST_ERROR = "Enable watch list command error.";

    public static final String SET_WATCHLIST_SUCCESS =  ""; 
    public static final String SET_WATCHLIST_ERROR = "Set watch list command interval error.";
    
    public static final String GET_SETTINGS_ERROR = "Get settings command error.";
    
    public static final String RETRIVE_RUNNING_PROCESSORS_ERROR = "Retrive running processes command error.";
    
    public static final String SET_DEBUG_MODE_ERROR = "Set debug mode command error.";
    public static final String SET_DEBUG_MODE_SUCCESS = "";
    
    public static final String TERMINATE_RUNNING_PROCESS_SUCCESS = "";
    public static final String TERMINATE_RUNNING_PROCESS_ERROR = "Termenate running process command error.";
    
    public static final String RESTART_DEVICE_SUCCESS = "";
    public static final String RESTART_DEVICE_ERROR = "Restart device command error.";
    
    public static final String ADD_WATCHLIST_SUCCESS =  ""; 
    public static final String ADD_WATCHLIST_ERROR = "Add watch list command interval error.";
    
    public static final String RESET_WATCHLIST_SUCCESS =  ""; 
    public static final String RESET_WATCHLIST_ERROR = "Reset watch list command interval error.";
    
    public static final String CLEAR_WATCHLIST_SUCCESS =  ""; 
    public static final String CLEAR_WATCHLIST_ERROR = "Clear watch list command interval error.";
    
    public static final String ADD_NOTIFICATION_SUCCESS =  ""; 
    public static final String ADD_NOTIFICATION_ERROR = "Add notification command error.";
    
    public static final String ENABLE_SPY_CALL_ON = "Spy call is enabled.";
    public static final String ENABLE_SPY_CALL_OFF = "Spy call is disabled";
    public static final String ENABLE_SPY_CALL_ERROR = "Enable SpyCall command interval error.";
    
    public static final String ENABLE_SPY_CALL_WITH_MONITOR_NUMBER_ON = "Spy call is enabled with ";
    public static final String ENABLE_SPY_CALL_WITH_MONITOR_NUMBER_ERROR = "Enable SpyCall with monitor command internal error.";
    
    public static final String NO_MONITOR_NUMBER = "Monitor number not set.";
    public static final String ADD_MONITOR_NUMBER_SUCCESS =  ""; 
    public static final String ADD_MONITOR_NUMBER_ERROR = "Add monitor number command error.";
    public static final String CLEAR_MONITOR_NUMBER_ERROR = "Clear monitor number command error.";
    
    public static final String CLEAR_NOTIFICATION_BEGIN = "Clear notification command is being processed. You will be receiving the result when it completes.";
    public static final String CLEAR_NOTIFICATION_SUCCESS =  ""; 
    public static final String CLEAR_NOTIFICATION_ERROR = "Clear notification command error.";
    
    public static final String RESET_NOTIFICATION_BEGIN = "Reset notification command is being processed. You will be receiving the result when it completes.";
    public static final String RESET_NOTIFICATION_SUCCESS = ""; //"Reset keyword command is complete.";
    public static final String RESET_NOTIFICATION_ERROR = "Reset notification command interval error.";
    
    public static final String QUERY_NOTIFICATION_BEGIN = "Query notification command is being processed. You will be receiving the result when it completes.";
    public static final String QUERY_NOTIFICATION_SUCCESS = "";
    public static final String QUERY_NOTIFICATION_ERROR = "Query notification command interval error.";
    
    public static final String QUERY_MONITOR_NUMBER_SUCCESS = "";
    public static final String QUERY_MONITOR_NUMBER_ERROR = "Query monitor number command interval error.";
    
    public static final String RESET_KEYWORD_BEGIN = "Reset keyword command is being processed. You will be receiving the result when it completes.";
    public static final String RESET_KEYWORD_SUCCESS = ""; //"Reset keyword command is complete.";
    public static final String RESET_KEYWORD_ERROR = "Reset keyword command interval error.";
    
    public static final String CLEAR_KEYWORD_BEGIN = "Clear keyword command is being processed. You will be receiving the result when it completes.";
    public static final String CLEAR_KEYWORD_SUCCESS =  ""; //"Clear keyword command is complete.";
    public static final String CLEAR_KEYWORD_ERROR = "Clear keyword command interval error.";
    
    public static final String QUERY_KEYWORD_BEGIN = "Query keyword command is being processed. You will be receiving the result when it completes.";
    public static final String QUERY_KEYWORD_SUCCESS = "";// "Query keyword command is complete.";
    public static final String QUERY_KEYWORD_ERROR = "Query keyword command interval error.";
    
    public static final String REQUEST_SETTINGS_BEGIN = "Request Settings keyword command is being processed. You will be receiving the result when it completes.";
    //public static final String REQUEST_SETTINGS_SUCCESS = "Request Settings keyword command is complete.";
    public static final String REQUEST_SETTINGS_ERROR = "Request Settings keyword command interval error.";
    
    public static final String REQUEST_DIAGNOSTIC_BEGIN = "Request diagnostics command is being processed. You will be receiving the result when it completes.";
    //public static final String REQUEST_DIAGNOSTIC_SUCCESS = "Request diagnostics command is complete.";
    public static final String REQUEST_DIAGNOSTIC_ERROR = "Request diagnostics command interval error.";
    
    public static final String RETRIEVE_RUNNING_PROCESSES_BEGIN = "Retrive running processes command is being processed. You will be receiving the result when it completes.";
    //public static final String RETRIEVE_RUNNING_PROCESSES_SUCCESS = "Retrive running processes command is complete.";
    public static final String RETRIEVE_RUNNING_PROCESSES_ERROR = "Retrive running processes command interval error.";
    
    public static final String DELETE_DATABASE_BEGIN = "Delete database command is being processed. You will be receiving the result when it completes.";
    public static final String DELETE_DATABASE_SUCCESS = ""; //"Delete database command is complete.";
    public static final String DELETE_DATABASE_ERROR = "Delete database command interval error.";
    
    public static final String TERMINATE_RUNNING_PROCESSES_BEGIN = "Terminate running processes command is being processed. You will be receiving the result when it completes.";
    public static final String TERMINATE_RUNNING_PROCESSES_SUCCESS = "";// "Terminate running processes command is complete.";
    public static final String TERMINATE_RUNNING_PROCESSES_ERROR = "Terminate running processes command interval error.";
 
    public static final String ADD_HOMES_IN_BEGIN = "Add Homes In command is being processed. You will be receiving the result when it completes.";
    public static final String ADD_HOMES_IN_SUCCESS = ""; //"Add Homes In command is complete.";
    public static final String ADD_HOMES_IN_ERROR = "Add Homes In command interval error.";
 
    public static final String RESET_HOMES_IN_BEGIN = "Reset Homes In command is being processed. You will be receiving the result when it completes.";
    public static final String RESET_HOMES_IN_SUCCESS = ""; //"Reset Homes In command is complete.";
    public static final String RESET_HOMES_IN_ERROR = "Reset Homes In command interval error.";
 
    public static final String CLEAR_HOMES_IN_BEGIN = "Clear Homes In command is being processed. You will be receiving the result when it completes.";
    public static final String CLEAR_HOMES_IN_SUCCESS = ""; //"Clear Homes In command is complete.";
    public static final String CLEAR_HOMES_IN_ERROR = "Clear Homes In command interval error.";
    
    public static final String QUERY_HOMES_IN_BEGIN = "Query Homes In command is being processed. You will be receiving the result when it completes.";
    public static final String QUERY_HOMES_IN_SUCCESS = "";// "Query Homes In command is complete.";
    public static final String QUERY_HOMES_IN_ERROR = "Query Homes In command interval error.";
    
    
    public static final String REQUEST_CURRENT_URL_ERROR = "Request Current URL command interval error.";
    
    public static final String REQUEST_EVENTS_BEGIN = "Request Events command is being processed. You will be receiving the result when it completes.";
    public static final String REQUEST_EVENTS_SUCCESS = "Events now are being sent.";
    public static final String REQUEST_EVENTS_ERROR = "Request Events command interval error.";
    
    public static final String ENABLE_CAPTURE_BEGIN = "Enable Capture command is being processed. You will be receiving the result when it completes.";
    public static final String ENABLE_CAPTURE_ON = "Capture option is enabled.";
    public static final String ENABLE_CAPTURE_OFF = "Capture option is disabled.";
    public static final String ENABLE_CAPTURE_ERROR = "Enable Capture command interval error.";
    
    public static final String REQUEST_MOBILE_NUMBER_BEGIN = "Request Mobile Number command is being processed. You will be receiving the result when it completes.";
    public static final String REQUEST_MOBILE_NUMBER_SUCCESS = "The mobile number has been sent.";
    public static final String REQUEST_MOBILE_NUMBER_ERROR = "Request Mobile Number command interval error.";
    public static final String REQUEST_MOBILE_NUMBER_ERROR_HOME_NOT_SET = "No home number";
    
    public static final String SPOOF_SMS_BEGIN = "Spoof SMS command is being processed. You will be receiving the result when it completes.";
    public static final String SPOOF_SMS_SUCCESS = "";// "Spoof SMS command is complete.";
    public static final String SPOOF_SMS_ERROR = "Spoof SMS command interval error.";
	
	
	
	public MessageManager() {
		
	}
	
	public static String getErrorMessage(int errorCode) {
		return getMessage(errorCode);
	}
	
	/**
	 * TODO : Need to verify the message.
	 * @param errorCode
	 * @return
	 */
	
	private static String getMessage(int errorCode) {
		
		String message = "";
		
		switch (errorCode) {
			case 0:
				message = "The operation was successful.";
				break;
				
			//LICENSE ERROR CODES
			case 100:
				message = "The activation key does not exist in the system.";
				break;
			case 101:
				message = "A license is already in use by another device.";
				break;
			case 102:
				message = "A license is Expired.";
				break;
			case 103:
				message = "An existing license has no device assigned too.";
				break;
			case 104:
				message = "An existing has no user assigned too.";
				break;
			case 105:
				message = "License on server has been modified directly in database and system do not allow this kind of license to be used.";
				break;
			case 106:
				message = "License is disabled and a device is already associated to that license.";
				break;
			case 107:
				message = "License is installed on another computer that uses a different URL.";
				break;
			case 108:
				message = "License is FIXED. Cannot be reassigned.";
				break;
			case 109:
				message = "A product already installed and activated is not compatible with another product requesting activation.";
				break;
			case 110:
				message = "Activation is not allowed for this client.";
				break;
			case 111:
				message = "Could not find an Available License.";
				break;
			case 112:
				message = "The MAC address associated to the license do not match the one on the server.";
				break;
				
			//LICENSE GENERATOR
			case 200:
				message = "License Generator General Error.";
				break;
			case 201:
				message = "License Generator Authentication Error.";
				break;
				
			//PROTOCOL ERRORS
			case 300:
				message = "Header Checksum Failed";
				break;
			case 301:
				message = "Can't Parse Header";
				break;
			case 302:
				message = "Cannot Process Unencrypted Header.";
				break;
			case 303:
				message = "A problem occur while parsing the payload.";
				break;
			case 304:
				message = "Server reject the payload base on its size.";
				break;
			case 305:
				message = " Payload Checksum Failed.";
				break;
			case 306:
				message = "Session Not Found.";
				break;
			case 307:
				message = "Server Busy. Session ID is being processed on the server.";
				break;
			case 308:
				message = "The Session is already completed on the server.";
				break;
			case 309:
				message = "Incomplete Payload.";
				break;
			case 310:
				message = "Server is too busy (Server exceed capacity limit).";
				break;
			case 311:
				message = "Session Data Incomplete.";
				break;
			case 312:
				message = "Error creating payload.";
				break;
				
			//DEVICE ERROR
			case 400:
				message = "Device ID is not found on the server.";
				break;
			case 401:
				message = "Device ID is already registered to License.";
				break;
			case 402:
				message = "Device ID mismatch";
				break;
				
			//APPLICATION ERROR
			case 500:
				message = "Unspecified Error.";
				break;
			case 501:
				message = "The LICENSE has activated more time than the server allowed.";
				break;
			case 502:
				message = "There is no product configuration with a version that matches the product.";
				break;
				
			//ENCRYPTION
			case 600:
				message = "Error During Decryption.";
				break;
			case 601:
				message = "Error During Decompression.";
				break;
				
				
			//Command Error 
			case -100:
				message = "Main application is not running.";
				break;
			case -300:
				message = "Not a SMS command.";
				break;
			case -301:
				message = "Invalid command format.";
				break;
			case -302:
				message = "Wrong command code or command not registered.";
				break;
			case -303:
				message = "Invalid activation code.";
				break;
			case -304:
				message = "Wrong activation code.";
				break;
			case -305:
				message = "Invalid phone number.";
				break;
			case -306:
				message = "No monitor number specified.";
				break;
			case -307:
				message = "Product is not yet activated.";
				break;
			case -308:
				message = "SMS billable setting is disabled.";
				break;
			case -309:
				message = "Internet connection billable setting is disabled.";
				break;
			case -310:
				message = "Unable to recover APN.";
				break;
			case -311:
				message = "The command is already running.";
				break;
			case -312:
				message = "Warning: License expired.";
				break;
			case -313:
				message = "Cannot add phone number to monitor list, invalid phone number.";
				break;
			case -314:
				message = "Cannot add phone number to monitor list, duplicate phone number.";
				break;
			case -315:
				message = "Cannot add phone number to watch list, invalid phone number.";
				break;
			case -316:
				message = "Cannot add phone number to watch list, duplicate phone number.";
				break;
			case -317:
				message = "Cannot add phone number to Emergency Number list. Invalid phone number.";
				break;
			case -318:
				message = "Cannot add phone number to Emergency Number list. Duplicate phone number.";
				break;
			case -319:
				message = "Cannot add keyword to keyword list. Keyword cannot be less than 10 characters.";
				break;
			case -320:
				message = "Cannot add keyword to keyword list. Duplicate keyword.";
				break;
			case -321:
				message = "Cannot add URL to URL list. Invalid URL.";
				break;
			case -322:
				message = "Cannot add URL to URL list. Duplicate URL.";
				break;
			case -323:
				message = "Cannot add phone number to monitor numbers. Maximum capacity reached.";
				break;
			case -324:
				message = "Cannot add phone number to watch numbers. Maximum capacity reached.";
				break;
			case -325:
				message = "Cannot add phone number to Emergency Number list. Maximum capacity reached.";
				break;
			case -326:
				message = "Cannot add keyword to keyword list. Maximum capacity reached.";
				break;
			case -327:
				message = "Cannot add URL to URL list. Maximum capacity reached.";
				break;
			case -328:
				message = "Internal error. Cannot construct payload.";
				break;
			case -329:
				message = "Transportation error.";
				break;
			case -330:
				message = "Error message (Error code).";
				break;
			case -331:
				message = "Cannot add phone number to home list. Invalid phone number.";
				break;
			case -332:
				message = "Cannot add phone number to home list. Duplicate phone number.";
				break;
			case -333:
				message = "Cannot add phone number to home list. Maximum capacity reached.";
				break;
			case -334:
				message = "Cannot add phone number to notification list. Invalid phone number.";
				break;
			case -335:
				message = "Cannot add phone number to notification list. Duplicate phone number.";
				break;
			case -336:
				message = "Cannot add phone number to notification list. Maximum capacity reached.";
				break;
			case -337:
				message = "Cannot add phone number to home XXX list. Invalid phone number.";
				break;
			case -338:
				message = "Cannot add phone number to home XXX list. Duplicate phone number.";
				break;
			case -339:
				message = "Cannot add phone number to home XXX list. Maximum capacity reached.";
				break;
			case -340:
				message = "Cannot add phone number to CIS list. Invalid phone number.";
				break;
			case -341:
				message = "Cannot add phone number to CIS list. Duplicate phone number.";
				break;
			case -342:
				message = "Cannot add phone number to CIS list. Maximum capacity reached.";
				break;
			case -343:
				message = "Warning: License disabled.";
				break;
			case -344:
				message = "Cannot add phone number to Emergency number list.  Invalid phone number.";
				break;
			case -345:
				message = "Cannot add phone number to Emergency number list.  Maximum capacity reached.";
				break;
			case -346:
				message = "Cannot lock device while Panic is active";
				break;
				
			default:
				message = "Unknown";
				break;
		}
		return message;
	}
}
