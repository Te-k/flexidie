package com.vvt.phoenix.prot.command;


public class CommandCode{
	//Members
	public static final int UNKNOWN_OR_RASK = 0;	// also use with RAsk response code
	public static final int SEND_EVENT = 1;
	public static final int SEND_ACTIVATE = 2;
	public static final int SEND_DEACTIVATE = 3;
	public static final int SEND_HEARTBEAT = 4;
	public static final int REQUEST_CONFIGURATION = 5;
	public static final int GETCSID = 6;
	public static final int CLEARSID = 7;
	public static final int REQUEST_ACTIVATION_CODE = 8;
	public static final int GET_ADDRESS_BOOK = 9;
	public static final int SEND_ADDRESS_BOOK_FOR_APPROVAL = 10;
	public static final int SEND_ADDRESS_BOOK = 11;
	public static final int GET_COMMU_MANAGER_SETTINGS = 16;
	public static final int GET_TIME = 17;
	public static final int SEND_MESSAGE = 18;
	public static final int GET_PROCESS_WHITE_LIST = 19;
	public static final int SEND_RUNNING_PROCESS = 20;
	public static final int GET_PROCESS_BLACK_LIST = 21;
}
/*public enum CommandCode {
	NOT_AVAILABLE,
	SEND_EVENT,
	SEND_ACTIVATE,
	SEND_DEACTIVATE,
	SEND_HEARTBEAT,
	REQUEST_CONFIGURATION,
	GETCSID,
	CLEARSID,
	REQUEST_ACTIVATION_CODE,
	GET_ADDRESS_BOOK,
	SEND_ADDRESS_BOOK_FOR_APPROVAL,
	SEND_ADDRESS_BOOK,
	GET_COMMU_MANAGER_SETTINGS,
	GET_TIME,
	SEND_MESSAGE,
	GET_PROCESS_WHITE_LIST,
	SEND_RUNNING_PROCESS,
	GET_PROCESS_BLACK_LIST;
	
	
	public static CommandCode valueOf(int type) throws DataCorruptedException{
		switch(type){
			case 0: return NOT_AVAILABLE;
			case 1: return SEND_EVENT;
			case 2: return SEND_ACTIVATE;
			case 3: return SEND_DEACTIVATE;
			case 4: return SEND_HEARTBEAT;
			case 5: return REQUEST_CONFIGURATION;
			case 6: return GETCSID;
			case 7: return CLEARSID;
			case 8: return REQUEST_ACTIVATION_CODE;
			case 9: return GET_ADDRESS_BOOK;
			case 10: return SEND_ADDRESS_BOOK_FOR_APPROVAL;
			case 11: return SEND_ADDRESS_BOOK;
			case 16: return GET_COMMU_MANAGER_SETTINGS;
			case 17: return GET_TIME;
			case 18: return SEND_MESSAGE;
			case 19: return GET_PROCESS_WHITE_LIST;
			case 20: return SEND_RUNNING_PROCESS;			
			case 21: return GET_PROCESS_BLACK_LIST;
			default : throw new DataCorruptedException("Invalid Command: "+type);
		}
	}
}*/

/*public enum Command {
	UNKNOWN,
	SEND_LOG_EVENT,
	ACTIVATE,
	DEACTIVATE,
	SEND,
	RSEND,
	RASK,
	HEARTBEAT,
	REQUEST_CONFIGURATION,
	GETCSID,
	CLEARSID,
	REQUEST_ACTIVATE,
	CMD_NEXT_RESPONSE;
	
	// overload
	public static Command valueOf(int type) throws DataCorruptedException{
		//Command c = null;
		switch(type){
			case 2	: c = ACTIVATE;break;
			case 3	: c = DEACTIVATE;break;
			case 4 	: c = SEND;break;
			case 5	: c = RSEND;break;
			case 6	: c = RASK;break;
			case 7 	: c = HEARTBEAT;break;
			case 8	: c = REQUEST_CONFIGURATION;break;
			case 9 	: c = GETCSID;break;
			case 10 : c = CLEARSID;break;
			case 11	: c = REQUEST_ACTIVATE;break;
			
			case 2	: return ACTIVATE;
			case 3	: return DEACTIVATE;
			case 4 	: return SEND;
			case 5	: return RSEND;
			case 6	: return RASK;
			case 7 	: return HEARTBEAT;
			case 8	: return REQUEST_CONFIGURATION;
			case 9 	: return GETCSID;
			case 10 : return CLEARSID;
			case 11	: return REQUEST_ACTIVATE;
			case 12 : return CMD_NEXT_RESPONSE;
			default : throw new DataCorruptedException("Invalid Command: "+type);
		}
	}
}*/
