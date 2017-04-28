package com.vvt.exceptions.io;

/**
 * @author Aruna
 * @version 1.0
 * @created 07-Aug-2011 02:45:55
 */
public class FxFileNotFoundException extends Throwable {
	
	private static final long serialVersionUID = 1L;
	
	public static final String UPLOAD_ACTUAL_MEDIA_FILE_NOT_FOUND = "Cannot capture media file. File has been removed. Pairing ID: %s";
	
	//public FxFileNotFoundException() { super(); }
	public FxFileNotFoundException(String s) { super(s); }
	public FxFileNotFoundException(String message, Throwable inner){ super(message, inner); { }}
}
