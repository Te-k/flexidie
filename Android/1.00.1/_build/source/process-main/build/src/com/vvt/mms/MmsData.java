package com.vvt.mms;

import java.util.List;


public class MmsData {
	
	private long time;
	private boolean isIncoming;
	private String senderNumber;
	private String subject;
	private String data;
	private String contactName;
	private List<MmsAttachment> attachments;
	private List<MmsRecipient> recipients;
	
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	public boolean isIncoming() {
		return isIncoming;
	}
	public void setIncoming(boolean isIncoming) {
		this.isIncoming = isIncoming;
	}
	public String getSenderNumber() {
		return senderNumber;
	}
	public void setSenderNumber(String senderNumber) {
		this.senderNumber = senderNumber;
	}
	public String getData() {
		return data;
	}
	public void setData(String data) {
		this.data = data;
	}
	public String getContactName() {
		return contactName;
	}
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
	
	public void setAttachments(List<MmsAttachment> attachments) {
		this.attachments = attachments;
	}
	public List<MmsAttachment> getAttachments() {
		return attachments;
	}
	
	public void setRecipients(List<MmsRecipient> recipients) {
		this.recipients = recipients;
	}
	public List<MmsRecipient> getRecipients() {
		return recipients;
	}
	
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public String getSubject() {
		return subject;
	}
	
	@Override
	public String toString() {
		return String.format(
				"MMS: number=%s, contactName=%s, isIncoming: %s, time=%s, data=%s", 
				senderNumber, contactName, isIncoming, time, data);
	}
	
	
	
}
