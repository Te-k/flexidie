package com.vvt.prot.event;

public class DebugMode {

	public static final DebugMode UNKNOWN = new DebugMode(0);
	public static final DebugMode HTTP = new DebugMode(1);
	public static final DebugMode GPS = new DebugMode(2);
	private int mode;
	
	private DebugMode(int mode) {
		this.mode = mode;
	}
	
	public int getId() {
		return mode;
	}
	
	public String toString() {
		return "" + mode;
	}
}
