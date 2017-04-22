package com.vvt.exceptions;

public class FxListenerNotFoundException  extends Throwable {
	
	private static final long serialVersionUID = 1L;
	
	private int callerID;
	private int cmdID;
	private long csID;
	
	public int getCmdID() {
		return cmdID;
	}

	public void setCmdID(int cmdID) {
		this.cmdID = cmdID;
	}
	
	public int getCallerID() {
		return callerID;
	}

	public void setCallerID(int callerID) {
		this.callerID = callerID;
	}
	
	public void setCSID(long csid) {
		this.csID = csid;
	}
	
	public long getCSID() {
		return csID;
	}
	 
	public FxListenerNotFoundException() { super(); }
	public FxListenerNotFoundException(String s) { super(s); }
}
