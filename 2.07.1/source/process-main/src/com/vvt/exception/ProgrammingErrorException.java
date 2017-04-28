package com.vvt.exception;

@SuppressWarnings("serial")
public final class ProgrammingErrorException extends RuntimeException {
	
//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
//------------------------------------------------------------------------------------------------------------------------
// PUBLIC API
//------------------------------------------------------------------------------------------------------------------------

	public ProgrammingErrorException(String aMessageString) {
		super(aMessageString);
	}
	
	public ProgrammingErrorException(String aMessageString, Throwable aThrowable) {
		super(aMessageString, aThrowable);
	}
	
	public ProgrammingErrorException(Throwable aThrowable) {
		super(aThrowable);
	}
}
