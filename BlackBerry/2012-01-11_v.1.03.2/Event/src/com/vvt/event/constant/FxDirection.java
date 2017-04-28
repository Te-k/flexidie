package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class FxDirection implements Persistable {
	
	public static final FxDirection UNKNOWN = new FxDirection(0);
	public static final FxDirection IN = new FxDirection(1);
	public static final FxDirection OUT = new FxDirection(2);
	public static final FxDirection MISSED_CALL = new FxDirection(3);
	public static final FxDirection LOCAL_IM = new FxDirection(4);
	private int id;
	
	private FxDirection(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
