package com.vvt.prot.event;
import java.util.Vector;

public class SMSEvent extends PMessageEvent {
	private String message = "";
	private Vector recipientStore = new Vector();
	
	public String getMessage() {
		return message;
	}
	
	public Recipient getRecipient(int index) {
		return (Recipient)recipientStore.elementAt(index);
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public void addRecipient(Recipient recipient) {
		recipientStore.addElement(recipient);
	}
	
	public short countRecipient() {
		return (short)recipientStore.size();
	}

	public EventType getEventType() {
		return EventType.SMS;
	}
}