package com.vvt.smsutil;

public class FxSMSMessage {
	
	private String contactName = "";
	private String number = "";
	private String message = "";
	
	public String getContactName() {
		return contactName;
	}
	
	public String getNumber() {
		return number;
	}

	public String getMessage() {
		return message;
	}
	
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
	
	public void setNumber(String number) {
		this.number = number;
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
}
