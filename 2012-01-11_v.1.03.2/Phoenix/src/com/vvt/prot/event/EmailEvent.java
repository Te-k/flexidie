package com.vvt.prot.event;

import java.util.Vector;

public class EmailEvent extends PMessageEvent {
	private String subject = "";
	private String message = "";
	private Vector recipientStore = new Vector();
	private Vector attachmentStore = new Vector();
	
	public String getSubject() {
		return subject;
	}
	
	public String getMessage() {
		return message;
	}
	
	public Recipient getRecipient(int index) {
		return (Recipient)recipientStore.elementAt(index);
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
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

	public Attachment getAttachment(int index) {
		return (Attachment)attachmentStore.elementAt(index);
	}
	
	public void addAttachment(Attachment attachment) {
		attachmentStore.addElement(attachment);
	}
	
	public short countAttachment() {
		return (short)attachmentStore.size();
	}
	
	public EventType getEventType() {
		return EventType.MAIL;
	}	
}
