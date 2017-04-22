package com.vvt.prot.event;
import java.util.Vector;

public class MMSEvent extends PMessageEvent {
	private String subject = null;
	private Vector attachmentStore = new Vector();
	private Vector recipientStore = new Vector();	
	private String senderNumb;
	
	public String getSenderNumber() {
		return senderNumb;
	}
	
	public void setSenderNumber(String senderNumb) {
		this.senderNumb = senderNumb;
	}
	
	public String getSubject() {
		return subject;
	}
	
	/*public Vector getAttachmentStore() {
		return attachmentStore;
	}*/
	
	public Attachment getAttachment(int index) {
		return (Attachment)attachmentStore.elementAt(index);
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
	}
	
	public void addAttachment(Attachment attachment) {
		attachmentStore.addElement(attachment);
	}
	
	public void addRecipient(Recipient recipient) {
		recipientStore.addElement(recipient);
	}
	
	public Recipient getRecipient(int index) {
		return (Recipient)recipientStore.elementAt(index);
	}
	
	public int lenghtOfSubject() {
		return subject.length();
	}
	
	/*public short countAttachment() {
		return (short)attachmentStore.size();
	}*/
	public byte countAttachment() {
		return (byte)attachmentStore.size();
	}
	
	public short countRecipient() {
		return (short)recipientStore.size();
	}

	public EventType getEventType() {
		return EventType.MMS;
	}
}