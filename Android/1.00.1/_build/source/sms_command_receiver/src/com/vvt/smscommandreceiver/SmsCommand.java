package com.vvt.smscommandreceiver;

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
	
}
