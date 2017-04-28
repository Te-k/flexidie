package com.vvt.exceptions.database;

public class FxDbIdNotFoundException extends Throwable{
	
	private static final long serialVersionUID = 1L;
	
	public static final String UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND = "Pairing Id: PAIRING_ID doesn't exist .Paring ID: %s";
	
	public FxDbIdNotFoundException(String error) {
		super(error);
	}
	
	public FxDbIdNotFoundException(String message, Throwable ex) { 
		super(message, ex); 
	}
}
