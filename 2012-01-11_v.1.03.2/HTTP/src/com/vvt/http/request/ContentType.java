package com.vvt.http.request;

public class ContentType {
	
	public static final ContentType FROMDATA = new ContentType("multipart/form-data");
//	public static final ContentType BINARY = new ContentType("binary/octet-stream");
	public static final ContentType BINARY = new ContentType("application/octet-stream");
	private String conType = "";
	
	private ContentType(String conType) {
		this.conType = conType;
	}
	
	public String toString() {
		return conType;
	}
	
}
