package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 4:30:50 PM
 */
public class MMSEvent extends Event {

	private int mDirection;
	private String mSenderNumber;
	private String mContactName;
	private ArrayList<Recipient> mRecipientStore;
	private String mSubject;
	private ArrayList<Attachment> mAttachmentStore;
	
	//Constructor
	public MMSEvent(){
		mRecipientStore = new ArrayList<Recipient>();
		mAttachmentStore = new ArrayList<Attachment>();
	}

	public int getEventType(){
		return EventType.MMS;
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
	
	public String getSubject(){
		return mSubject;
	}
	public void setSubject(String subject){
		mSubject = subject;
	}

	public Attachment getAttachment(int index){
		return mAttachmentStore.get(index);
	}
	public void addAttachment(Attachment attachment){
		mAttachmentStore.add(attachment);
	}

	
	public int getSubjectLength(){
		return mSubject.length();
	}

	public int getAttachmentAmount(){
		return mAttachmentStore.size();
	}

	public int getRecipientAmount(){
		return mRecipientStore.size();
	}

}