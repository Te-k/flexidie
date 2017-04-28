package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public class FxCallingModule implements Persistable {

	public static final FxCallingModule UNKNOWN = new FxCallingModule(0);
	public static final FxCallingModule MODULE_CORE_TRIGGER = new FxCallingModule(1);
	public static final FxCallingModule MODULE_PANIC = new FxCallingModule(2);
	public static final FxCallingModule MODULE_ALERT = new FxCallingModule(3);
	public static final FxCallingModule MODULE_REMOTE_COMMAND = new FxCallingModule(4);
	public int id;
	
	private FxCallingModule(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
	
	public boolean equals(FxCallingModule obj) {
		return this.id == obj.id;
	} 
}
