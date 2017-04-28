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

	/**
	 * 
	 * @param name    name
	 */
	public void setAttachemntFullName(String name){
		mAttachmentFullName = name;
	}

	public byte[] getAttachmentData(){
		return mAttachmentData;
	}

	/**
	 * 
	 * @param data    data
	 */
	public void setAttachmentData(byte[] data){
		mAttachmentData= data;
	}

}