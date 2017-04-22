package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 2:49:34 PM
 */
public class SMSEvent extends Event {

	private long mId;	// use locally only
	private int mDirection;
	private String mSenderNumber;
	private String mContactName;
	private ArrayList<Recipient> mRecipientStore;
	private String mSMSData;
	
	//Constructor
	public SMSEvent(){
		mRecipientStore = new ArrayList<Recipient>();
	}
	
	public int getEventType(){
		return EventType.SMS;
	}
	
	public long getId(){
		return mId;
	}
	public void setId(long id){
		mId = id;
	}
	
	public int getDirection(){
		return mDirection;
	}
	/**
	 * @param direction from EventDirection
	 */
	public void setDirection(int direction){
		mDirection = direction;
	}
	
	public String getSenderNumber(){
		return mSenderNumber;
	}
	public void setSenderNumber(String number){
		mSenderNumber = number;
	}

	public String getContactName(){
		return mContactName;
	}
	public void setContactName(String name){
		mContactName = name;
	}
	
	public Recipient getRecipient(int index){
		return mRecipientStore.get(index);
	}
	public void addRecipient(Recipient recipient){
		mRecipientStore.add(recipient);
	}
	
	public String getSMSData(){
		return mSMSData;
	}
	public void setSMSData(String message){
		mSMSData = message;
	}

	
	public int getRecipientAmount(){
		return mRecipientStore.size();
	}

}