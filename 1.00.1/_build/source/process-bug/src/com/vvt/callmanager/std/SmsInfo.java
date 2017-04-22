package com.vvt.callmanager.std;

public class SmsInfo {
	
	public enum SmsType { GSM, CDMA };
	
	private SmsType type;
	private String phoneNumber;
	private String messageBody;
	private boolean moreMsgToSend;
	
	public SmsType getType() {
		return type;
	}

	public void setType(SmsType type) {
		this.type = type;
	}
	public String getPhoneNumber() {
		return phoneNumber;
	}
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
	public String getMessageBody() {
		return messageBody;
	}
	public void setMessageBody(String messageBody) {
		this.messageBody = messageBody;
	}
	public boolean hasMoreMsgToSend() {
		return moreMsgToSend;
	}
	public void setMoreMsgToSend(boolean moreMsgToSend) {
		this.moreMsgToSend = moreMsgToSend;
	}
	
	@Override
	public String toString() {
		return String.format("number: %s, messageBody: %s", phoneNumber, messageBody);
	}
	
}
