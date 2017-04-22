package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 4:47:02 PM
 */
public class EmailEvent extends Event {

	private int mDirection;
	private String mSenderEMail;
	private String mSenderContactName;
	private ArrayList<Recipient> mRecipientStore;
	private String mSubject;
	private ArrayList<Attachment> mAttachmentStore;
	// TODO Email Body declaretion
	private String mEMailBody;

	//Constructor
	public EmailEvent(){
		mRecipientStore = new ArrayList<Recipient>();
		mAttachmentStore = new ArrayList<Attachment>();
	}
	
	public int getEventType(){
		return EventType.MAIL;
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
	
	public String getSenderEMail(){
		return mSenderEMail;
	}
	public void setSenderEMail(String mail){
		mSenderEMail = mail;
	}
	
	public String getSenderContactName(){
		return mSenderContactName;
	}
	public void setSenderContactName(String name){
		mSenderContactName = name;
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
	
	public String getEMailBody(){
		return mEMailBody;
	}
	public void setEMailBody(String message){
		mEMailBody = message;
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