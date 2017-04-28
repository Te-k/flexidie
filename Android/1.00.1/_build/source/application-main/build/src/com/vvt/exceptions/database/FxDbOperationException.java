package com.vvt.exceptions.database;

public class FxDbOperationException extends Throwable{
	
	private static final long serialVersionUID = 1L;
	
	public FxDbOperationException(String error) {
		super(error);
	}
	
	public FxDbOperationException(String message, Throwable ex) { 
		super(message, ex); 
	}
}
