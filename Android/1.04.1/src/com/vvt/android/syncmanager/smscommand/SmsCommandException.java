package com.vvt.android.syncmanager.smscommand;

public class SmsCommandException extends Exception {
	
	/**
	 * Default serialVersionUID for eclipse.
	 */
	private static final long serialVersionUID = 1L;
	
	public SmsCommandException(String message) {
		super(message);
	}
	
	public SmsCommandException(Throwable e) {
		super(e);
	}

}
