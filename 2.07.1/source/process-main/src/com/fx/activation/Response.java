package com.fx.activation;

import com.fx.activation.ActivationManager.Status;

public class Response {

	private boolean isActivateAction;
	private boolean isSuccess;
	private String message;
	private Status activationStatus = Status.DEACTIVATED;
	private byte responseCode = -1;
	private String hashCode;
	
	public Response() {
		
	}
	
	public Response(boolean success, String message, Status activationStatus) {
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
	
	public String getMessage() {
		return message;
	}
	
	public Status getActivationStatus() {
		return activationStatus;
	}
	
	public byte getResponseCode() {
		return responseCode;
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
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public void setActivationStatus(Status status) {
		this.activationStatus = status;
	}
	
	public void setResponseCode(byte code) {
		this.responseCode = code;
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
		builder.append(String.format("activationStatus: %s", activationStatus));
		return builder.toString();
	}
	
}
