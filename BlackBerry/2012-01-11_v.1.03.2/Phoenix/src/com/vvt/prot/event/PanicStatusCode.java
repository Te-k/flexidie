package com.vvt.prot.event;

public class PanicStatusCode {

	public static final PanicStatusCode UNKNOWN = new PanicStatusCode(0);
	public static final PanicStatusCode PANIC_STARTED = new PanicStatusCode(1);
	public static final PanicStatusCode PANIC_ENDED = new PanicStatusCode(2);
	private int status;
	
	private PanicStatusCode(int status) {
		this.status = status;
	}
	
	public int getId() {
		return status;
	}
}
