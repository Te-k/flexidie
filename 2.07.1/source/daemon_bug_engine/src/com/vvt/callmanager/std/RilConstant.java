package com.vvt.callmanager.std;

public interface RilConstant {
	
	public int RIL_REQUEST_GET_CURRENT_CALLS = 9;
	public int RIL_REQUEST_DIAL = 10;
	public int RIL_REQUEST_HANGUP = 12;
	public int RIL_REQUEST_HANGUP_BACKGROUND = 13;
	public int RIL_REQUEST_HANGUP_FOREGROUND = 14;
	public int RIL_REQUEST_SWITCH_CALLS = 15;
	public int RIL_REQUEST_CONFERENCE = 16;
	public int RIL_REQUEST_SEND_SMS = 25;
	public int RIL_REQUEST_SEND_SMS_EXPECT_MORE = 26;
	public int RIL_REQUEST_SMS_ACKNOWLEDGE = 37;
	public int RIL_REQUEST_ANSWER = 40;
	public int RIL_REQUEST_SET_MUTE = 53;
	public int RIL_REQUEST_CDMA_FLASH = 84;
	public int RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE = 88;
	public int RIL_UNSOL_CALL_STATE_CHANGED = 1001;
	public int RIL_UNSOL_NEW_SMS = 1003;
	public int RIL_UNSOL_SIGNAL_STRENGTH = 1009;
	public int RIL_UNSOL_CALL_RING = 1018; // Nexus One don't get this when having a waiting call
	public int RIL_UNSOL_CDMA_NEW_SMS = 1020;
	public int RIL_UNSOL_CDMA_CALL_WAITING = 1025;
    
	public int RIL_REQUEST_HANGUP_LG = 204; // also use for hang up background
    
	public int RIL_UNSOL_LG_CALL_STATE_INFO = 1049;
	public int RIL_UNSOL_HTC_CALL_RING = 1510; // Found in HTC Hero 2.1 update1
}
