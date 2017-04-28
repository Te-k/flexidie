package com.vvt.exceptions.database;

public abstract class FxDatabaseException extends Throwable {
	
	private static final long serialVersionUID = 1L;
	
	public FxDatabaseException() { super(); }
	public FxDatabaseException(String s) { super(s); }
	public FxDatabaseException(String message, Throwable inner){ super(message, inner); { }}
}