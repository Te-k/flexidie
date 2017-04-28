package com.vvt.prot.unstruct;

public class UnstructCmdCode {

	public static final UnstructCmdCode UCMD_KEY_EXCHANGE = new UnstructCmdCode(100);
	public static final UnstructCmdCode UCMD_ACKNOWLEDGE_SECURE = new UnstructCmdCode(101);
	public static final UnstructCmdCode UCMD_ACKNOWLEDGE = new UnstructCmdCode(102);
	public static final UnstructCmdCode UCMD_PING = new UnstructCmdCode(103);
	private int cmdCode;
	
	private UnstructCmdCode(int cmdCode) {
		this.cmdCode = cmdCode;
	}
	
	public int getId() {
		return cmdCode;
	}
	
	public String toString() {
		return "" + cmdCode;
	}
	
}
