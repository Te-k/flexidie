package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:19:21
 */
public class FxIMEvent extends FxEvent {

	/**
	 * Members
	 */
	private FxEventDirection mEventDirection;
	private String mUserId;
	private ArrayList<FxParticipant> mParticipantList;
	private String mImServiceId;
	private String mMessage;
	private String mUserDisplayName;

	public FxIMEvent()
	{
		mParticipantList = new ArrayList<FxParticipant>();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.IM;
	}
	
	public FxEventDirection getEventDirection(){
		return mEventDirection;
	}

	/**
	 * 
	 * @param direction    direction
	 */
	public void setEventDirection(FxEventDirection direction){
		mEventDirection = direction;
	}

	public String getUserId(){
		return mUserId;
	}

	/**
	 * 
	 * @param id    id
	 */
	public void setUserId(String id){
		mUserId= id;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxParticipant getParticipant(int index){
		return mParticipantList.get(index);
	}

	/**
	 * 
	 * @param participant    participant
	 */
	public void addParticipant(FxParticipant participant){
		mParticipantList.add(participant);
	}
	
	public int getParticipantCount(){
		if(mParticipantList != null)
			return mParticipantList.size();
		else 
			return 0;
	}

	public String getImServiceId(){
		return mImServiceId;
	}

	/**
	 * 
	 * @param id    id
	 */
	public void setImServiceId(String id){
		mImServiceId = id;
	}

	public String getMessage(){
		return mMessage;
	}

	/**
	 * 
	 * @param message    message
	 */
	public void setMessage(String message){
		mMessage= message;
	}

	public String getUserDisplayName(){
		return mUserDisplayName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setUserDisplayName(String name){
		mUserDisplayName = name;
	}

}