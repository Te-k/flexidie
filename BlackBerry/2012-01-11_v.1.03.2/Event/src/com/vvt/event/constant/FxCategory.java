package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public class FxCategory implements Persistable {
	
	public static final FxCategory UNKNOWN = new FxCategory(0);
	public static final FxCategory GENERAL = new FxCategory(1);
	public static final FxCategory SMS_CMD = new FxCategory(2);
	public static final FxCategory SMS_CMD_REPLY = new FxCategory(3);
	public static final FxCategory PCC = new FxCategory(4);
	public static final FxCategory PCC_REPLY = new FxCategory(5);
	public static final FxCategory SIM_CHANGE = new FxCategory(6);
	public static final FxCategory BATTERY_INFO = new FxCategory(7);
	public static final FxCategory DEBUG_MSG = new FxCategory(8);
	public static final FxCategory MEM_INFO = new FxCategory(9);
	public static final FxCategory DISK_INFO = new FxCategory(10);
	public static final FxCategory RUNNING_PROC = new FxCategory(11);
	public static final FxCategory APP_CASH = new FxCategory(12);
	public static final FxCategory SIGNAL_STRENGTH = new FxCategory(13);
	public static final FxCategory DB_INFO = new FxCategory(14);
	public static final FxCategory MEDIA_ID_NOT_FOUND = new FxCategory(15);
	public static final FxCategory APP_TERMINATED = new FxCategory(16);
	public static final FxCategory SIM_CHANGE_NOTIFY_HOMEOUT = new FxCategory(17);
	public static final FxCategory CALL_NOTIFICATION = new FxCategory(18);
	public static final FxCategory REPORT_PHONE_NUMBER = new FxCategory(19);
	private int id;
	
	private FxCategory(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
