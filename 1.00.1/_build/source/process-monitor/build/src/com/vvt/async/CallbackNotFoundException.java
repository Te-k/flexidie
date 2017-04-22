package com.vvt.async;

public class CallbackNotFoundException extends RuntimeException{

	private static final long serialVersionUID = 1L;
	
	public CallbackNotFoundException() { super(); }
	public CallbackNotFoundException(String s) { super(s); }

}
