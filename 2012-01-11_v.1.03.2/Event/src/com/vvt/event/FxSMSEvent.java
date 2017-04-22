package com.vvt.event;

import java.util.Vector;
import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxSMSEvent extends FxMessageEvent implements Persistable {
	
	private String message = "";
	private Vector recipientStore = new Vector();
	
	public FxSMSEvent() {
		setEventType(EventType.SMS);
	}
	
	public String getMessage() {
		return message;
	}
	
	public FxRecipient getRecipient(int index) {
		return (FxRecipient)recipientStore.elementAt(index);
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
