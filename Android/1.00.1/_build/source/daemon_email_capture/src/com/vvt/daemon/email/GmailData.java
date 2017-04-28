package com.vvt.daemon.email;

import java.util.Arrays;
import java.util.List;

public class GmailData {

	private long time;
	private String dateTime;
	private boolean isInbox;
	private int size;
	private String sender;
	private String senderName;
	private String[] to;
	private String[] cc;
	private String[] bcc;
	private String subject;
	private String[] attachments;
	private List<GmailAttachment> gmailAttachments;
	private String body;
	private String contactName;
	
	public GmailData() {
		
	}
	
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	public String getDateTime() {
		return dateTime;
	}
	public void setDateTime(String dateTime) {
		this.dateTime = dateTime;
	}
	public boolean isInbox() {
		return isInbox;
	}
	public void setInbox(boolean isInbox) {
		this.isInbox = isInbox;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}
	public String getSender() {
		return sender;
	}
	public void setSender(String sender) {
		this.sender = sender;
	}
	public String[] getTo() {
		return to;
	}
	public void setTo(String[] to) {
		this.to = to;
	}
	public String[] getCc() {
		return cc;
	}
	public void setCc(String[] cc) {
		this.cc = cc;
	}
	public String[] getBcc() {
		return bcc;
	}
	public void setBcc(String[] bcc) {
		this.bcc = bcc;
	}
	public String getSubject() {
		return subject;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public String[] getAttachments() {
		return attachments;
	}
	public void setAttachments(String[] attachments) {
		this.attachments = attachments;
	}
	public String getBody() {
		return body;
	}
	public void setBody(String body) {
		this.body = body;
	}
	public String getReciverContactName() {
		return contactName;
	}
	public void setReciverContactName(String contactName) {
		this.contactName = contactName;
	}
	
	public void setGmailAttachments(List<GmailAttachment> gmailAttachments) {
		this.gmailAttachments = gmailAttachments;
	}
	public List<GmailAttachment> getGmailAttachments() {
		return gmailAttachments;
	}
	
	
	@Override
	public String toString() {
		return String.format("Gmail: sender=%s, receiver=%s, contactName=%s, subject=%s", 
				sender, Arrays.toString(to), contactName, subject);
	}

	public String getSenderName() {
		return senderName;
	}

	public void setSenderName(String senderName) {
		this.senderName = senderName;
	}
	
}
