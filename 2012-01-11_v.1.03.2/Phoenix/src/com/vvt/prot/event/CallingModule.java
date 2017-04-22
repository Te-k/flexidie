package com.vvt.prot.event;

public class CallingModule {

	public static final CallingModule UNKNOWN = new CallingModule(0);
	public static final CallingModule MODULE_CORE_TRIGGER = new CallingModule(1);
	public static final CallingModule MODULE_PANIC = new CallingModule(2);
	public static final CallingModule MODULE_ALERT = new CallingModule(3);
	public static final CallingModule MODULE_REMOTE_COMMAND = new CallingModule(4);
	public int id;
	
	private CallingModule(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
