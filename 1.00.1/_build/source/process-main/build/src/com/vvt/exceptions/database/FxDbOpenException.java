package com.vvt.exceptions.database;

public class FxDbOpenException extends Throwable {

	private static final long serialVersionUID = 1L;
	
	public FxDbOpenException(String error) {
		super(error);
	}
	
	public FxDbOpenException(String message, Throwable ex) { 
		super(message, ex); 
	}
	
}
