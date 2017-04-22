package com.vvt.events;


/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:44:04
 */
public class FxRecipient {

	private FxRecipientType mRecipientType;
	private String mRecipient;
	private String mContactName;

 
	public FxRecipientType getRecipientType(){
		return mRecipientType;
	}

	/**
	 * 
	 * @param recipientType    recipientType
	 */
	public void setRecipientType(FxRecipientType recipientType){
		mRecipientType = recipientType;
	}

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

	@Override
	public String toString() {
		return String.format("Gmail: RecipientType=%s, Recipient=%s, contactName=%s ", 
				mRecipientType, mRecipient, mContactName);
	}
	
	

}