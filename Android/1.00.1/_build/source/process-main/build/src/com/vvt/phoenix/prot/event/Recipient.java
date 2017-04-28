package com.vvt.phoenix.prot.event;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 3:06:27 PM
 */
public class Recipient {

	private int mRecipientType;
	private String mRecipient;
	private String mContactName;
	
	//Constructor
	/*public Recipient(){
		mRecipientType = null;
		mRecipient = null;
		mContactName = null;
	}*/

	public int getRecipientType(){
		return mRecipientType;
	}
	public void setRecipientType(int recipientType){
		mRecipientType = recipientType;
	}

	public String getRecipient(){
		return mRecipient;
	}
	public void setRecipient(String recipient){
		mRecipient = recipient;
	}
	
	public String getContactName(){
		return mContactName;
	}
	public void setContactName(String contactName){
		mContactName = contactName;
	}

}