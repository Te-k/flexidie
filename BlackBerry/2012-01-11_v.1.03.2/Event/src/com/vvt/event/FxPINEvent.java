package com.vvt.event;

import java.util.Vector;
import com.vvt.event.constant.EventType;
import net.rim.device.api.util.Persistable;

public class FxPINEvent extends FxMessageEvent implements Persistable {

	private String subject = "";
	private String message = "";
	private Vector recipientStore = new Vector();
	
	public FxPINEvent() {
		setEventType(EventType.PIN);
	}
	
	public String getSubject() {
		return subject;
	}
	
	public String getMessage() {
		return message;
	}
	
	public FxRecipient getRecipient(int index) {
		return (FxRecipient)recipientStore.elementAt(index);
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public void addRecipient(FxRecipient recipient) {
		recipientStore.addElement(recipient);
	}
	
	public int countRecipient() {
		return recipientStore.size();
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += subject.getBytes().length; // subject
		size += message.getBytes().length; // message
		for (int i = 0; i < countRecipient(); i++) {
			FxRecipient rep = getRecipient(i);
			size += rep.getContactName().getBytes().length; // ContactName
			size += rep.getRecipient().getBytes().length; // Recipient
			size += 2; // RecipientType
		}
		return size;
	}
}
