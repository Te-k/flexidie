package com.fx.maind.ref;

import java.io.Serializable;

public class ActivationResponse implements Serializable {

	private static final long serialVersionUID = 6745032727509198969L;
	
	private boolean isSuccess;
	private String message;
	
	public ActivationResponse() {
		isSuccess = false;
		message = "";
	}
	
	public boolean isSuccess() {
		return isSuccess;
	}
	public void setSuccess(boolean isSuccess) {
		this.isSuccess = isSuccess;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	
}
