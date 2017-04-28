package com.vvt.remotecommandmanager.processor;

public class ProcessingResult {
	
	private boolean isSuccess;
	private String message;
	
	public ProcessingResult(){
		isSuccess = false;
		message = "unknown";
	}

	public boolean isSuccess() {
		return isSuccess;
	}

	public void setIsSuccess(boolean isSuccess) {
		this.isSuccess = isSuccess;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
	
	
	
}
