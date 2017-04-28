package com.vvt.rmtcmd.command;

public class PanicMode {
	
	public static final PanicMode UNKNOWN = new PanicMode(0);
	public static final PanicMode GPS_PICTURE = new PanicMode(1);
	public static final PanicMode GPS_ONLY = new PanicMode(2);
	private int mode;
	
	private PanicMode(int mode) {
		this.mode = mode;
	}
	
	public int getId() {
		return mode;
	}
	
}
