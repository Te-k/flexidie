package com.fx.dalvik.activation;

import com.fx.dalvik.activation.ActivationManager.Status;

public class ActivationResponse {

	private boolean isActivateAction;
	private boolean isSuccess;
	private byte responseCode = -1;
	private int httpStatusCode;
	private String message;
	private Status activationStatus = Status.DEACTIVATED;
	private String hashCode;
	
	public ActivationResponse() {
		
	}
	
	public ActivationResponse(boolean success, String message, Status activationStatus) {
		this.isSuccess = success;
		this.message = message;
		this.activationStatus = activationStatus;
	}
	
	public boolean isActivateAction() {
		return isActivateAction;
	}
	
	public boolean isSuccess() {
		return isSuccess;
	}
	
	public byte getResponseCode() {
		return responseCode;
	}
	
	public int getHttpStatusCode() {
		return httpStatusCode;
	}
	
	public String getMessage() {
		return message;
	}
	
	public Status getActivationStatus() {
		return activationStatus;
	}
	
	public String getHashCode() {
		return hashCode;
	}
	
	public void setActivateAction(boolean value) {
		isActivateAction = value;
	}
	
	public void setSuccess(boolean value) {
		isSuccess = value;
	}
	
	public void setResponseCode(byte responseCode) {
		this.responseCode = responseCode;
	}
	
	public void setHttpStatusCode(int httpStatusCode) {
		this.httpStatusCode = httpStatusCode;
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public void setActivationStatus(Status status) {
		this.activationStatus = status;
	}
	
	public void setHashCode(String hashCode) {
		this.hashCode = hashCode;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("isActivateAction: %s, ", isActivateAction));
		builder.append(String.format("isSuccess: %s, ", isSuccess));
		builder.append(String.format("message: %s, ", message));
		builder.append(String.format("activationStatus: %s, ", activationStatus));
		builder.append(String.format("hashCode: %s", hashCode));
		return builder.toString();
	}
	
}
