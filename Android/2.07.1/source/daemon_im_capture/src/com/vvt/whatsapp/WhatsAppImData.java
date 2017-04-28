package com.vvt.whatsapp;

import java.util.ArrayList;

public class WhatsAppImData {
	
	private long time;
	private String mData;
	private boolean mIsSent;
	private String mDateTime;
	private String mSpeakerUid;
	private String mSpeakerName;
	private ArrayList<String> mParticipantUids;
	private boolean mIsGroupChat;
	private String mOwner;
	private String mOwnerUid;
	
	public WhatsAppImData(){
		mData = "";
		mIsSent = false;
		mDateTime = "";
		mSpeakerUid = ""; 
		mParticipantUids = new ArrayList<String>();
		mIsGroupChat = false;
		mOwner = "";
	}
	
	public void setData(String data) {
		this.mData= data;
	}
	
	public String getData() {
		return this.mData;
	}
	
	public void setSent(boolean is_sent) {
		this.mIsSent = is_sent;
	}
	
	public boolean isSent() {
		return this.mIsSent;
	}
	
	public void setDateTime(String dateTimeReceive) {
		this.mDateTime = dateTimeReceive;
	}
	
	public String getDateTime() {
		return this.mDateTime;
	}
	
	public void setTime(long time) {
		this.time = time;
	}
	
	public long getTime() {
		return this.time;
	}
	
	public void setSpeakerName(String speakName) {
		this.mSpeakerName = speakName;
	}
	
	public String getSpeakName() {
		return this.mSpeakerName;
	}
	
	public void setSpeakerUid(String speaker) {
		this.mSpeakerUid = speaker;
	}
	
	public String getSpeakerUid() {
		return this.mSpeakerUid;
	}
	
	public void setParticipantUids(ArrayList<String> contact) {
		if(this.mParticipantUids == null) {
			this.mParticipantUids = new ArrayList<String>();
		}
		this.mParticipantUids.addAll(contact);
	}
	
	public ArrayList<String> getParticipantUids() {
		return this.mParticipantUids;
	}
	
	public void setIsGroupChat(boolean isGroupChat) {
		this.mIsGroupChat = isGroupChat;
	}
	
	public boolean isGroupChat() {
		return this.mIsGroupChat;
	}
	
	public void setOwner(String owner) {
		this.mOwner = owner;
	}
	
	public String getOwner() {
		return this.mOwner;
	}
	
	public void setOwnerUid(String ownerUid) {
		this.mOwnerUid = ownerUid;
	}
	
	public String getOwnerUid() {
		return this.mOwnerUid;
	}
}
