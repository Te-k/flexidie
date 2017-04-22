package com.vvt.exceptions.database;

public class FxDbCorruptException extends Throwable {
	
	private static final long serialVersionUID = 1L;
	
	public FxDbCorruptException() { super(); }
	public FxDbCorruptException(String s) { super(s); }
	public FxDbCorruptException(String message, Throwable inner){ super(message, inner); { }}
}