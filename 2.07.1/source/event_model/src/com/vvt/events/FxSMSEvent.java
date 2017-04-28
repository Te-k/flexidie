package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:55:40
 */
public class FxSMSEvent extends FxEvent {

	private FxEventDirection mDirection;
	private String mSenderNumber;
	private String mContactName;
	private ArrayList<FxRecipient> mRecipientStore;
	private String mSMSData;
	public FxRecipient m_FxRecipient;

	public FxSMSEvent()
	{
		mRecipientStore = new ArrayList<FxRecipient>();
		m_FxRecipient = new FxRecipient();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.SMS;
	}

	public FxEventDirection getDirection(){
		return mDirection;
	}

	/**
	 * 
	 * @param direction    from EventDirection
	 */
	public void setDirection(FxEventDirection direction){
		mDirection = direction;
	}

	public String getSenderNumber(){
		return mSenderNumber;
	}

	/**
	 * 
	 * @param number    number
	 */
	public void setSenderNumber(String number){
		mSenderNumber = number;
	}

	public String getContactName(){
		return mContactName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setContactName(String name){
		mContactName = name;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxRecipient getRecipient(int index){
		return mRecipientStore.get(index);
	}

	/**
	 * 
	 * @param recipient    recipient
	 */
	public void addRecipient(FxRecipient recipient){
		mRecipientStore.add(recipient);
	}

	public String getSMSData(){
		return mSMSData;
	}

	/**
	 * 
	 * @param message    message
	 */
	public void setSMSData(String message){
		mSMSData = message;
	}

	/**
	 * 
	 * @return Recipient size.
	 */
	public int getRecipientCount() {
		return mRecipientStore.size();
	}
 
	
	
}