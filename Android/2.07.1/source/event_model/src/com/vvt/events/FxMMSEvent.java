package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 12:30:11
 */
public class FxMMSEvent extends FxEvent {

	private FxEventDirection m_Direction;
	private String m_SenderNumber;
	private String m_ContactName;
	private ArrayList<FxRecipient> m_RecipientStore;
	private String m_Subject;
	private ArrayList<FxAttachment> m_AttachmentStore;
	public FxAttachment m_Attachment;
	
	public FxMMSEvent()
	{
		m_AttachmentStore = new ArrayList<FxAttachment>();
		m_RecipientStore = new ArrayList<FxRecipient>();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.MMS;
	}

	public FxEventDirection getDirection(){
		return m_Direction;
	}

	/**
	 * 
	 * @param direction    from EventDirection
	 */
	public void setDirection(FxEventDirection direction){
		m_Direction = direction;
	}

	public String getSenderNumber(){
		return m_SenderNumber;
	}

	/**
	 * 
	 * @param number    number
	 */
	public void setSenderNumber(String number){
		m_SenderNumber = number;
	}

	public String getContactName(){
		return m_ContactName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setContactName(String name){
		m_ContactName = name;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxRecipient getRecipient(int index){
		return m_RecipientStore.get(index);
	}

	/**
	 * mRecipientStore.add(recipient)
	 * 
	 * @param recipient    recipient
	 */
	public void addRecipient(FxRecipient recipient){
		m_RecipientStore.add(recipient);
	}
	
	
	public int getRecipientCount(){
		return m_RecipientStore.size();
	}

	public String getSubject(){
		return m_Subject;
	}

	/**
	 * 
	 * @param subject    subject
	 */
	public void setSubject(String subject){
		m_Subject = subject;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxAttachment getAttachment(int index){
		return m_AttachmentStore.get(index);
	}

	/**
	 * 
	 * @param attachment    attachment
	 */
	public void addAttachment(FxAttachment attachment){
		m_AttachmentStore.add(attachment);
	}
	
	public int getAttachmentCount() {
		return m_AttachmentStore.size();
	}

	public int getSubjectLength(){
		return m_Subject.length();
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxMMSEvent {");
		builder.append(" EventId =").append(super.getEventId());
		
		if(getDirection() == FxEventDirection.IN) {
			builder.append(", Direction =").append("IN");
		}
		else if(getDirection() == FxEventDirection.OUT) {
			builder.append(", Direction =").append("OUT"); 
		}
		else {
				builder.append(", Direction =").append("Invalid");
		}

		builder.append(", SenderNumber =").append(getSenderNumber());
		builder.append(", Subject =").append(getSubject());
		
		builder.append(", Recipient Count =").append(m_RecipientStore.size());
		for(FxRecipient r: m_RecipientStore) {
			builder.append(" Recipient ContactName =").append(r.getContactName());
			builder.append(", Recipient Number =").append(r.getRecipient());
		}
		
		builder.append(", Attachment Count =").append(m_AttachmentStore.size());
		for(FxAttachment a: m_AttachmentStore) {
			builder.append(", Recipient Attachment FullName =").append(a.getAttachmentFullName());
			builder.append(", Recipient Attachment Size =").append(a.getAttachmentData().length);
		}
				
		builder.append(", ContactName =").append(getContactName());
		builder.append(", EventTime =").append(super.getEventTime());
		return builder.append(" }").toString();
	}
}