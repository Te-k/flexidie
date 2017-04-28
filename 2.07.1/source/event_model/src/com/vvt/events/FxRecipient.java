package com.vvt.events;

public class FxRecipient {

	private FxRecipientType mRecipientType;
	private String mRecipient;
	private String mContactName;

 
	public FxRecipientType getRecipientType(){
		return mRecipientType;
	}

	public void setRecipientType(FxRecipientType recipientType){
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

	@Override
	public String toString() {
		return String.format("%s: %s(%s)", mRecipientType, mContactName, mRecipient);
	}

}