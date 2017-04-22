package com.vvt.prot.event;

import com.vvt.event.constant.FxCategory;

public class Category {
	
	public static final Category UNKNOWN = new Category(0);
	public static final Category GENERAL = new Category(1);
	public static final Category SMS_CMD = new Category(2);
	public static final Category SMS_CMD_REPLY = new Category(3);
	public static final Category PCC = new Category(4);
	public static final Category PCC_REPLY = new Category(5);
	public static final Category SIM_CHANGE = new Category(6);
	public static final Category BATTERY_INFO = new Category(7);
	public static final Category DEBUG_MSG = new Category(8);
	public static final Category MEM_INFO = new Category(9);
	public static final Category DISK_INFO = new Category(10);
	public static final Category RUNNING_PROC = new Category(11);
	public static final Category APP_CASH = new Category(12);
	public static final Category SIGNAL_STRENGTH = new Category(13);
	public static final Category DB_INFO = new Category(14);
	public static final Category MEDIA_ID_NOT_FOUND = new Category(15);
	public static final Category APP_TERMINATED = new Category(16);
	public static final Category SIM_CHANGE_NOTIFY_HOMEOUT = new Category(17);
	public static final Category CALL_NOTIFICATION = new Category(18);
	public static final Category REPORT_PHONE_NUMBER = new Category(19);
	private int id;
	
	private Category(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
