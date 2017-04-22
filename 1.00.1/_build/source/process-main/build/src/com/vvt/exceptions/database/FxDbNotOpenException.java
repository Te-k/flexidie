package com.vvt.exceptions.database;

public class FxDbNotOpenException extends FxDatabaseException {
	
	private static final long serialVersionUID = 1L;
	
	public FxDbNotOpenException(String error) {
		super(error);
	}
	
	public FxDbNotOpenException(String message, Throwable ex) { 
		super(message, ex); 
	}
}
