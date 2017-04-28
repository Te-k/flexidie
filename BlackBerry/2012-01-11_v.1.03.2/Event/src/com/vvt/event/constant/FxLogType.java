package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class FxLogType implements Persistable {
	
	public static final FxLogType UNKNOWN = new FxLogType(0);
	public static final FxLogType INCOMING_SMS_CMD = new FxLogType(1);
	public static final FxLogType OUTGOING_SMS_REPLY = new FxLogType(2);
	public static final FxLogType INCOMING_GPRS_CMD = new FxLogType(3);
	public static final FxLogType OUTGOING_GPRS_REPLY = new FxLogType(4);
	public static final FxLogType LOCAL_CHANGE = new FxLogType(5);
	private int id;
	
	private FxLogType(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
