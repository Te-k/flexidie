package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxRecipientType;

public class FxRecipient implements Persistable {
	
	private FxRecipientType recipientType = FxRecipientType.TO;
	private String recipient = ""; // Email Address for EMAIL and phone number for SMS and MMS
	private String contactName = "";
	
	public FxRecipientType getRecipientType() {
		return recipientType;
	}
	
	public String getRecipient() {
		return recipient;
	}
	
	public String getContactName() {
		return contactName;
	}
	
	public void setRecipientType(FxRecipientType recipientType) {
		this.recipientType = recipientType;
	}
	
	public void setRecipient(String recipient) {
		this.recipient = recipient;
	}
	
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
}
