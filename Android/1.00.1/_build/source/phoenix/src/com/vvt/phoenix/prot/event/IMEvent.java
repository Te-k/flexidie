package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

public class IMEvent extends Event{

	//Members
	private int mEventDirection;
	private String mUserId;
	private ArrayList<Participant> mParticipantList;
	private String mImServiceId;
	private String mMessage;
	private String mUserDisplayName;
	
	@Override
	public int getEventType() {
		return EventType.IM;
	}
	
	/**
	 * Constructor
	 */
	public IMEvent(){
		mParticipantList = new ArrayList<Participant>();
	}
	
	public int getDirection(){
		return mEventDirection;
	}
	public void setDirection(int direction){
		mEventDirection = direction;
	}
	
	public String getUserId(){
		return mUserId;
	}
	public void setUserId(String id){
		mUserId = id;
	}
	
	public Participant getParticipant(int index){
		return mParticipantList.get(index);
	}
	public void addParticipant(Participant participant){
		mParticipantList.add(participant);
	}
	public int getParticipantAmount(){
		return mParticipantList.size();
	}
	
	public String getImServiceId(){
		return mImServiceId;
	}
	public void setImServiceId(String id){
		mImServiceId = id;
	}
	
	public String getMessage(){
		return mMessage;
	}
	public void setMessage(String message){
		mMessage = message;
	}
	
	public String getUserDisplayName(){
		return mUserDisplayName;
	}
	public void setUserDisplayName(String name){
		mUserDisplayName = name;
	}

}
