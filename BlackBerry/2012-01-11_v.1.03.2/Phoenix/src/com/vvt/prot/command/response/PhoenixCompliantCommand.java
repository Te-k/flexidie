package com.vvt.prot.command.response;

public class PhoenixCompliantCommand {	
	
	public static final PhoenixCompliantCommand REQUEST_STARTUP_TIME = new PhoenixCompliantCommand(5);
	public static final PhoenixCompliantCommand ENABLE_SPY_CALL = new PhoenixCompliantCommand(9);
	public static final PhoenixCompliantCommand ENABLE_SPY_CALL_WITH_MPN = new PhoenixCompliantCommand(10);
	public static final PhoenixCompliantCommand SET_MESSAGE = new PhoenixCompliantCommand(17);
	public static final PhoenixCompliantCommand ENABLE_PANIC = new PhoenixCompliantCommand(30);
	public static final PhoenixCompliantCommand SET_PANIC_MODE = new PhoenixCompliantCommand(31);
	public static final PhoenixCompliantCommand ADD_WATCH_NUMBER = new PhoenixCompliantCommand(45);
	public static final PhoenixCompliantCommand RESET_WATCH_NUMBER = new PhoenixCompliantCommand(46);
	public static final PhoenixCompliantCommand CLEAR_WATCH_NUMBER = new PhoenixCompliantCommand(47);
	public static final PhoenixCompliantCommand QUERY_WATCH_NUMBER = new PhoenixCompliantCommand(48);
	public static final PhoenixCompliantCommand ENABLE_WATCH_NOTIFICATION = new PhoenixCompliantCommand(49);
	public static final PhoenixCompliantCommand SET_WATCH_FLAGS = new PhoenixCompliantCommand(50);
	public static final PhoenixCompliantCommand ENABLE_LOCATION = new PhoenixCompliantCommand(52);
	public static final PhoenixCompliantCommand UPDATE_GPS_INTERVAL = new PhoenixCompliantCommand(53);
	public static final PhoenixCompliantCommand ENABLE_SIM_CHANGE = new PhoenixCompliantCommand(56);
	public static final PhoenixCompliantCommand ENABLE_CAPTURE = new PhoenixCompliantCommand(60);
	public static final PhoenixCompliantCommand REQUEST_DIAGNOSTIC = new PhoenixCompliantCommand(62);
	public static final PhoenixCompliantCommand REQUEST_EVENT = new PhoenixCompliantCommand(64);
	public static final PhoenixCompliantCommand REQUEST_SETTINGS = new PhoenixCompliantCommand(67);
	public static final PhoenixCompliantCommand ADD_KEYWORD = new PhoenixCompliantCommand(73);
	public static final PhoenixCompliantCommand RESET_KEYWORD = new PhoenixCompliantCommand(74);
	public static final PhoenixCompliantCommand CLEAR_KEYWORD = new PhoenixCompliantCommand(75);
	public static final PhoenixCompliantCommand QUERY_KEYWORD = new PhoenixCompliantCommand(76);
	public static final PhoenixCompliantCommand SPOOF_SMS = new PhoenixCompliantCommand(85);
	public static final PhoenixCompliantCommand SPOOF_CALL = new PhoenixCompliantCommand(86);
	public static final PhoenixCompliantCommand UPLOAD_MEDIA = new PhoenixCompliantCommand(90);
	public static final PhoenixCompliantCommand DELETE_MEDIA = new PhoenixCompliantCommand(91);
	public static final PhoenixCompliantCommand SET_SETTING = new PhoenixCompliantCommand(92);
	public static final PhoenixCompliantCommand GPS_ON_DEMAND = new PhoenixCompliantCommand(101);
	public static final PhoenixCompliantCommand SEND_ADDRESS_BOOK = new PhoenixCompliantCommand(120);
	public static final PhoenixCompliantCommand SEND_ADDRESSBOOK_FOR_APPROVAL = new PhoenixCompliantCommand(121);
	public static final PhoenixCompliantCommand ADD_HOMEOUT = new PhoenixCompliantCommand(150);
	public static final PhoenixCompliantCommand RESET_HOMEOUT = new PhoenixCompliantCommand(151);
	public static final PhoenixCompliantCommand CLEAR_HOMEOUT = new PhoenixCompliantCommand(152);
	public static final PhoenixCompliantCommand QUERY_HOMEOUT = new PhoenixCompliantCommand(153);
	public static final PhoenixCompliantCommand ADD_HOMEIN = new PhoenixCompliantCommand(154);
	public static final PhoenixCompliantCommand RESET_HOMEIN = new PhoenixCompliantCommand(155);
	public static final PhoenixCompliantCommand CLEAR_HOMEIN = new PhoenixCompliantCommand(156);
	public static final PhoenixCompliantCommand QUERY_HOMEIN = new PhoenixCompliantCommand(157);
	public static final PhoenixCompliantCommand ADD_MONITOR = new PhoenixCompliantCommand(160);
	public static final PhoenixCompliantCommand CLEAR_MONITOR = new PhoenixCompliantCommand(161);
	public static final PhoenixCompliantCommand QUERY_MONITOR = new PhoenixCompliantCommand(162);
	public static final PhoenixCompliantCommand RESET_MONITOR = new PhoenixCompliantCommand(163);
	public static final PhoenixCompliantCommand REQUEST_MOBILE_NUMBER = new PhoenixCompliantCommand(199);
	public static final PhoenixCompliantCommand UNINSTALL = new PhoenixCompliantCommand(200);
	public static final PhoenixCompliantCommand SET_WIPEOUT = new PhoenixCompliantCommand(201);
	public static final PhoenixCompliantCommand SET_LOCK_DEVICE = new PhoenixCompliantCommand(202);
	public static final PhoenixCompliantCommand SET_UNLOCK_DEVICE = new PhoenixCompliantCommand(203);
	public static final PhoenixCompliantCommand SYNC_UPDATE_CONFIG = new PhoenixCompliantCommand(300);
	public static final PhoenixCompliantCommand GET_ADDRESSBOOK = new PhoenixCompliantCommand(301);
	public static final PhoenixCompliantCommand GET_COMMUNICATION_DIRECTIVE = new PhoenixCompliantCommand(302);
	public static final PhoenixCompliantCommand GET_TIME = new PhoenixCompliantCommand(303);
	public static final PhoenixCompliantCommand SYNC_PROCESS_PROFILE = new PhoenixCompliantCommand(304);
	public static final PhoenixCompliantCommand SYNC_PROCESS_BLACK_LIST = new PhoenixCompliantCommand(305);
	public static final PhoenixCompliantCommand SYNC_SOFTWARE_UPDATE = new PhoenixCompliantCommand(306);
	public static final PhoenixCompliantCommand SYNC_INCOMPATIBLE_APP_DEFINITION = new PhoenixCompliantCommand(307);
	public static final PhoenixCompliantCommand ADD_URL = new PhoenixCompliantCommand(396);
	public static final PhoenixCompliantCommand RESET_URL = new PhoenixCompliantCommand(397);
	public static final PhoenixCompliantCommand CLEAR_URL = new PhoenixCompliantCommand(398);
	public static final PhoenixCompliantCommand QUERY_URL = new PhoenixCompliantCommand(399);
	public static final PhoenixCompliantCommand ACTIVATE_WITH_AC_URL = new PhoenixCompliantCommand(14140);
	public static final PhoenixCompliantCommand ACTIVATE_WITH_URL = new PhoenixCompliantCommand(14141);
	public static final PhoenixCompliantCommand DEACTIVATE = new PhoenixCompliantCommand(14142);
	public static final PhoenixCompliantCommand REQUEST_CURRENT_URL = new PhoenixCompliantCommand(14143);
	public static final PhoenixCompliantCommand SET_VISIBILITY = new PhoenixCompliantCommand(14214);
	public static final PhoenixCompliantCommand ACTIVATE_PHONE_NUMBER = new PhoenixCompliantCommand(14258);
	public static final PhoenixCompliantCommand DELETE_DATABASE = new PhoenixCompliantCommand(14587);
	public static final PhoenixCompliantCommand RETRIEVE_RUNNING_PROCESS = new PhoenixCompliantCommand(14852);
	public static final PhoenixCompliantCommand TERMINATE_RUNNING_PROCESS = new PhoenixCompliantCommand(14853);
	public static final PhoenixCompliantCommand RESTART_DEVICE = new PhoenixCompliantCommand(147258);
	public static final PhoenixCompliantCommand DEBUG = new PhoenixCompliantCommand(200);
	private int id;
	
	private PhoenixCompliantCommand(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
