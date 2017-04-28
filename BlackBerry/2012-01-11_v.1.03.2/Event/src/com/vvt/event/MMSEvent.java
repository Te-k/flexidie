package com.vvt.event;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class MMSEvent extends FxMessageEvent implements Persistable {
	
	private String subject = null;
	private Vector attachmentStore = new Vector();
	private Vector recipientStore = new Vector();	
	
	public String getSubject() {
		return subject;
	}
	
	public Vector getAttachmentStore() {
		return attachmentStore;
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
	}
	
	public void addAttachment(Attachment attachment) {
		attachmentStore.addElement(attachment);
	}
	
	public void addRecipient(FxRecipient recipient) {
		recipientStore.addElement(recipient);
	}
	
	public int lenghtOfSubject() {
		return subject.length();
	}
	
	public short countAttachment() {
		return (short)attachmentStore.size();
	}
	
	public short countRecipient() {
		return (short)recipientStore.size();
	}
}