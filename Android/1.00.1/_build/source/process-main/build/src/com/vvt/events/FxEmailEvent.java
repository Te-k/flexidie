package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
 

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 12:17:52
 */
public class FxEmailEvent extends FxEvent {

	private FxEventDirection m_Direction;
	private String m_SenderEMail;
	private String m_SenderContactName;
	private ArrayList<FxRecipient> m_RecipientStore;
	private String m_Subject;
	private ArrayList<FxAttachment> m_AttachmentStore;
 	private String m_EMailBody;
 	 

	public FxEmailEvent()
	{
		m_RecipientStore = new ArrayList<FxRecipient>();
		m_AttachmentStore = new ArrayList<FxAttachment>();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.MAIL;
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

	public String getSenderEMail(){
		return m_SenderEMail;
	}

	/**
	 * 
	 * @param mail    mail
	 */
	public void setSenderEMail(String mail){
		m_SenderEMail = mail;
	}

	public String getSenderContactName(){
		return m_SenderContactName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setSenderContactName(String name){
		m_SenderContactName = name;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxRecipient getRecipient(int index){
		return m_RecipientStore.get(index);
	}
	
	/**
	 * get number of Recipient
	 * 
	 */
	public int getRecipientCount(){
		return m_RecipientStore.size();
	}

	/**
	 * 
	 * @param recipient    recipient
	 */
	public void addRecipient(FxRecipient recipient){
		m_RecipientStore.add(recipient);
	}

	public String getSubject(){
		return m_Subject;
	}

	/**
	 * mSubject = subject
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
	 * get number of Attachment.
	 */
	public int getAttachmentCount(){
		return m_AttachmentStore.size();
	}

	/**
	 * 
	 * @param attachment    attachment
	 */
	public void addAttachment(FxAttachment attachment){
		m_AttachmentStore.add(attachment);
	}

	public String getEMailBody(){
		return m_EMailBody;
	}

	/**
	 * 
	 * @param message    message
	 */
	public void setEMailBody(String message){
		m_EMailBody= message;
	}

	public int getSubjectLength(){
		return m_Subject.length();
	}

}