package com.vvt.prot.event;

public class Recipient {
	private RecipientTypes recipientType = RecipientTypes.TO;
	private String recipient = ""; // Email Address for EMAIL and phone number for SMS and MMS
	private String contactName = "";
	
	public RecipientTypes getRecipientType() {
		return recipientType;
	}
	
	public String getRecipient() {
		return recipient;
	}
	
	public String getContactName() {
		return contactName;
	}
	
	public void setRecipientType(RecipientTypes recipientType) {
		this.recipientType = recipientType;
	}
	
	public void setRecipient(String recipient) {
		this.recipient = recipient;
	}
	
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
}
