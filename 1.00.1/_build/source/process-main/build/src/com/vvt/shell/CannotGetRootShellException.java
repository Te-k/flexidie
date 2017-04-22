package com.vvt.shell;

public class CannotGetRootShellException extends Exception {
	
	private static final long serialVersionUID = 1L;
	
	public enum Reason { UNKNOWN, SU_EXEC_FAILED, SYSTEM_WRITE_FAILED};
	
	private Reason mReason = Reason.UNKNOWN;
	
	public CannotGetRootShellException() {
		super();
	}
	
	public CannotGetRootShellException(Reason reason) {
		mReason = reason;
	}
	
	public Reason getReason() {
		return mReason;
	}
}
