package com.vvt.http.request;

public class MethodType {

	public static final MethodType GET = new MethodType("GET");
	public static final MethodType POST = new MethodType("POST");
	private String method = "";
	
	private MethodType(String method) {
		this.method = method;
	}
	
	public String toString() {
		return method;
	}
	
}