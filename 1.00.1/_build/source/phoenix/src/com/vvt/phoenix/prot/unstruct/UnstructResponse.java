package com.vvt.phoenix.prot.unstruct;

/**
 * @author tanakharn
 * @version 1.0
 * @updated 20-Oct-2010 4:23:20 PM
 */
public abstract class UnstructResponse {
	private int mStatusCode;
	
	// mIsOk and mErrorMsg use for indicate that Exception occur while parsing response
	private boolean mIsOk;
	private String mErrorMsg;
	
	//public abstract UnstructCmdCode getCmdEcho();
	
	public UnstructResponse(){
		mStatusCode = -1;
	}
	
	public int getStatusCode(){
		return mStatusCode;
	}
	public void setStatusCode(int code){
		mStatusCode = code;
	}
	
	public boolean isResponseOk(){
		return mIsOk;
	}
	public void setResponseFlag(boolean flag){
		mIsOk = flag;
	}
	
	public String getErrorMessage(){
		return mErrorMsg;
	}
	public void setErrorMessage(String msg){
		mErrorMsg = msg;
	}
}
