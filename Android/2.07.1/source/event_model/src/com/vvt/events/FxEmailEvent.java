package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxEmailEvent extends FxEvent {

	private ArrayList<FxAttachment> attachments;
	private ArrayList<FxRecipient> recipients;
	private FxEventDirection direction;
	private String displayTime;
	private String subject;
	private String emailBody;
 	private String senderEmail;
	private String senderContactName;

	public FxEmailEvent() {
		recipients = new ArrayList<FxRecipient>();
		attachments = new ArrayList<FxAttachment>();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.MAIL;
	}
	
	public void setDisplayTime(String displayTime) {
		this.displayTime = displayTime;
	}
	
	public String getDisplayTime() {
		return displayTime;
	}

	public FxEventDirection getDirection(){
		return direction;
	}

	public void setDirection(FxEventDirection direction){
		this.direction = direction;
	}

	public String getSenderEmail(){
		return senderEmail;
	}

	public void setSenderEmail(String mail){
		senderEmail = mail;
	}

	public String getSenderContactName(){
		return senderContactName;
	}

	public void setSenderContactName(String name){
		senderContactName = name;
	}

	public FxRecipient getRecipient(int index){
		return recipients.get(index);
	}
	
	public int getRecipientCount(){
		return recipients.size();
	}

	public void addRecipient(FxRecipient recipient){
		recipients.add(recipient);
	}

	public String getSubject(){
		return subject;
	}

	public void setSubject(String subject){
		this.subject = subject;
	}

	public FxAttachment getAttachment(int index){
		return attachments.get(index);
	}
	
	public int getAttachmentCount(){
		return attachments.size();
	}

	public void addAttachment(FxAttachment attachment){
		attachments.add(attachment);
	}

	public String getEmailBody(){
		return emailBody;
	}

	public void setEmailBody(String message){
		emailBody= message;
	}

	public int getSubjectLength(){
		return subject.length();
	}
	
	@Override
	public String toString() {
		return String.format("time: %s, subject: %s, sender: %s (%s), recipients: %s", 
				displayTime, subject, senderEmail, senderContactName, recipients);
	}

}