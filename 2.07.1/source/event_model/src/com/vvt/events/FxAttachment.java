package com.vvt.events;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:44:11
 */
public class FxAttachment {

	private String mAttachmentFullName;
	private byte mAttachmentData[];

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
		mAttachmentData= data;
	}
	
	@Override
	public String toString() {
		return mAttachmentFullName;
	}

}