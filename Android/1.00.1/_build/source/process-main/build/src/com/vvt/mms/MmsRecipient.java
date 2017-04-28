package com.vvt.mms;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:44:04
 */
public class MmsRecipient {

	private String mRecipient;
	private String mContactName;

	/**
	 * return mRecipient
	 */
	public String getRecipient(){
		return mRecipient;
	}

	/**
	 * mRecipient = recipient
	 * 
	 * @param recipient    recipient
	 */
	public void setRecipient(String recipient){
		mRecipient = recipient;
	}

	/**
	 * return mContactName
	 */
	public String getContactName(){
		return mContactName;
	}

	/**
	 * mContactName = contactName
	 * 
	 * @param contactName    contactName
	 */
	public void setContactName(String contactName){
		mContactName = contactName;
	}

}