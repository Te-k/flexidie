package com.vvt.prot;

public class RequestType {
	public static final RequestType NEW_REQUEST = new RequestType(1);
	public static final RequestType RESUME_REQUEST = new RequestType(2);
	private int type;
	
	private RequestType(int type) {
		this.type = type;
	}
	
	public int getId() {
		return type;
	}
	
	public String toString() {
		return "" + type;
	}
}
