package com.vvt.smsutil;

import java.util.Date;
import javax.wireless.messaging.TextMessage;

public class MultipartMessage implements TextMessage {
	
	private byte smsId = 0;
	private String phoneNumber = null;
	private String message = null;
	
	public void setSmsId(byte smsId) {
		this.smsId = smsId;
	}

	public void setPayloadText(String message) {
		this.message = message;
	}
	
	public void setAddress(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
	
	public byte getSmsId() {
		return smsId;
	}

	public String getPayloadText() {
		return message;
	}
	
	public String getAddress() {
		return phoneNumber;
	}

	public Date getTimestamp() {
		return null;
	}
	
	public void appendPayloadText(String message) {
		this.message += message;
	}
}
