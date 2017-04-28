package com.fx.dalvik.resource;

import com.vvt.security.Constant;
import com.vvt.security.FxSecurity;

public class StringResource {
	public static final String HASH_TAIL = FxSecurity.getConstant(Constant.HASH_TAIL);
	public static final String DEFAULT_FLEXI_KEY = FxSecurity.getConstant(Constant.DEFAULT_FLEXI_KEY);
	public static final String SMS_COMMAND_TAG = FxSecurity.getConstant(Constant.SMS_COMMAND_TAG);
	
	public static final String URL_RETAIL_ACTIVATION = FxSecurity.getConstant(Constant.URL_RETAIL_ACTIVATION);
	public static final String URL_RETAIL_LOG = FxSecurity.getConstant(Constant.URL_RETAIL_LOG);
	public static final String URL_RESELLER_ACTIVATION = FxSecurity.getConstant(Constant.URL_RESELLER_ACTIVATION);
	public static final String URL_RESELLER_LOG = FxSecurity.getConstant(Constant.URL_RESELLER_LOG);
	public static final String URL_TEST_ACTIVATION = FxSecurity.getConstant(Constant.URL_TEST_ACTIVATION);
	public static final String URL_TEST_LOG = FxSecurity.getConstant(Constant.URL_TEST_LOG);
	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_OK = "OK";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_ERROR = "Error";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_WATCH_LIST_FULL = "Watchlist full.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_WARNING_MONITOR_NUMBER = "Warning: Your monitor number not set. Set number using correct parameters.";	
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_NOT_A_COMMAND = "Not a command message.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT = "Invalid command format.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_COMMAND_NOT_FOUND = "Command not found or not registered.";
	public static final String LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_ACTIVATION_CODE = "Invalid Activation Code.";
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
	
	public static final String LANG_ABOUT_INFO = "Product: %s<br/>Version: %s<br/>Date: %s";
	public static final String LANG_DELIVERY_PARTIAL_SUCCESS = "Successfully sent %d events. Tried to send %d events";
}
