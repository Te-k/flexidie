package com.vvt.prot.event;

public class Attachment {
	private String attachmentFullName = "";
	private byte[] attachmentData = null;
	
	public String getAttachmentFullName() {
		return attachmentFullName;
	}
	
	public byte[] getAttachmentData() {
		return attachmentData;
	}
	
	public void setAttachmentFullName(String attachmentFullName) {
		this.attachmentFullName = attachmentFullName;
	}
	
	public void setAttachmentData(byte[] attachmentData) {
		this.attachmentData = attachmentData;
	}
}
