package com.vvt.connectionhistorymanager;

/**
 * @author Aruna
 * @version 1.0
 * @created 07-Nov-2011 04:46:55
 */
public class CommandCode {
	public static final int UNKNOWN_OR_RASK = 0;	// also use with RAsk response code
	public static final int SEND_EVENT = 1;
	public static final int SEND_ACTIVATE = 2;
	public static final int SEND_DEACTIVATE = 3;
	public static final int SEND_HEARTBEAT = 4;
	public static final int GET_CONFIGURATION = 5;
	public static final int GETCSID = 6;
	public static final int CLEARSID = 7;
	public static final int GET_ACTIVATION_CODE = 8;
	public static final int GET_ADDRESS_BOOK = 9;
	public static final int SEND_ADDRESS_BOOK_FOR_APPROVAL = 10;
	public static final int SEND_ADDRESS_BOOK = 11;
	public static final int GET_COMMU_MANAGER_SETTINGS = 16;
	public static final int GET_TIME = 17;
	public static final int SEND_MESSAGE = 18;
	public static final int GET_PROCESS_PROFILE = 19;
	public static final int SEND_RUNNING_PROCESS = 20;
	public static final int GET_PROCESS_BLACK_LIST = 21;
	public static final int GET_INCOMPATIBLE_APPLICATION_DEFINITION = 23;
	public static final int SEND_CALL_IN_PROGRESS = 24;
	
	public static String toReadableName (int code) {

		switch(code) {
			case SEND_ACTIVATE:
				return "Activation";
			case SEND_DEACTIVATE:
				return "Deactivation";
			case SEND_EVENT:
				return "Send log events";
			case CLEARSID:
				return "Clear CSID";
			case SEND_HEARTBEAT:
				return "Heartbeat";
			case SEND_RUNNING_PROCESS:
				return "Send Processes";
			case SEND_ADDRESS_BOOK:
				return "Send address book";
			case SEND_ADDRESS_BOOK_FOR_APPROVAL:
				return "Send addr. book for appr.";
			case SEND_CALL_IN_PROGRESS:
				return "Send Call in Progress";
			case GETCSID:
				return "Get CSID";
			case GET_TIME:
				return "Get time";
			case GET_PROCESS_PROFILE:
				return "Get Process Profile";
			case GET_COMMU_MANAGER_SETTINGS:
				return "Get restrictions";
			case GET_CONFIGURATION:
				return "Get Configuration";
			case GET_ACTIVATION_CODE:
				return "Get act code";
			case GET_ADDRESS_BOOK:
				return "Get address book";
			case GET_INCOMPATIBLE_APPLICATION_DEFINITION:
				return "Get incomp.app";
		}
		
		return "Code not found.";
	}	
}