package com.vvt.remotecommandmanager;

/**
 * This class is the bride between RCM and UI for SMS commands
 * @author Aruna
 *
 */
public class SmsCommand {
	private String senderNumber;
	private String message;
	
	public SmsCommand() {
		
	}

	public String getSenderNumber() {
		return senderNumber;
	}

	public void setSenderNumber(String senderNumber) {
		this.senderNumber = senderNumber;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
	
	@Override
	public String toString() {
		return new StringBuilder().append("SmsCommand { senderNumber : ")
				.append(senderNumber).append("message:").append(message).append(" }").toString();
	}
}
