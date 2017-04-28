package com.vvt.http.response;

import com.vvt.http.request.FxHttpRequest;

public class FxHttpResponse {
	
	private FxHttpRequest mRequest;
	private int mResponseCode;
	private byte[] mBody;
	private boolean mComplete;
	private String transType = "-";
	
	public FxHttpResponse() {
		mRequest = null;
		mResponseCode = 0;
		mBody = null;
		mComplete = false;		
	}
	
	public FxHttpRequest getRequest() {
		return mRequest;
	}
	
	public void setRequest(FxHttpRequest request) {
		mRequest = request;
	}
	
	public int getResponseCode() {
		return mResponseCode;
	}
	
	public void setResponseCode(int code) {
		mResponseCode = code;
	}
	
	public String getTransType() {
		return transType;
	}
	
	public void setTransType(String type) {
		transType = type;
	}
	
	public byte[] getBody() {
		return mBody;
	}
	
	public void setBody(byte[] body) {
		mBody = body;
	}
	
	public boolean isComplete(){
		return mComplete;
	}
	
	public void setIsComplete(boolean status) {
		mComplete = status;
	}
}
