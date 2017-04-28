package com.vvt.exceptions.io;

public class FxFileSizeNotAllowedException extends Throwable {
	
	private static final long serialVersionUID = 1L;
	
	public static final String UPLOAD_ACTUAL_MEDIA_FILE_SIZE_NOT_ALLOWED = "Cannot capture media file. File is bigger than 10 MB. Pairing ID: %s";
	
	public FxFileSizeNotAllowedException(String error) {
		super(error);
	}
	
	public FxFileSizeNotAllowedException(String message, Throwable ex) { 
		super(message, ex); 
	}
}
