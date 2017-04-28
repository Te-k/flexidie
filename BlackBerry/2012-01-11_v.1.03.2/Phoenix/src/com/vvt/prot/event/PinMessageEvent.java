package com.vvt.prot.event;

import java.util.Vector;

public class PinMessageEvent extends PMessageEvent {
	private String subject = "";
	private String message = "";
	private Vector recipientStore = new Vector();
	
	public String getSubject() {
		return subject;
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
	}
	
	public String getMessage() {
		return message;
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public Recipient getRecipient(int index) {
		return (Recipient)recipientStore.elementAt(index);
	}
	
	public void addRecipient(Recipient recipient) {
		recipientStore.addElement(recipient);
	}
	
	public short countRecipient() {
		return (short)recipientStore.size();
	}
	
	public EventType getEventType() {
		return EventType.PIN_MESSAGE;
	}

}
