package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 31-May-2010 4:34:28 PM
 */
public class Attachment {

	private String mAttachmentFullName;
	private byte[] mAttachmentData;
	
	//Constructor
	public Attachment(){
		mAttachmentFullName = null;
		mAttachmentData = null;
	}
	
	public String getAttachmentFullName(){
		return mAttachmentFullName;
	}
	public void setAttachemntFullName(String name){
		mAttachmentFullName = name;
	}
	
	public byte[] getAttachmentData(){
		return mAttachmentData;
	}
	public void setAttachmentData(byte[] data){
		mAttachmentData = data;
	}

}