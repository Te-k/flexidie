package com.vvt.phoenix.prot.event;

/**
 * @author yongyuth
 * @version 1.0
 * @created 31-May-2010 11:06:30 AM
 */
public class CallLogEvent extends Event {

	private long mId; // this field is not a part of protocol, using locally only.
	private int mDirection;
	private long mDuration;
	private String mNumber;
	private String mContactName;
	
	@Override
	public int getEventType(){
		return EventType.CALL_LOG;
	}

	public long getId(){
		return mId;
	}
	public void setId(long id){
		mId  = id;
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
	
	public long getDuration(){
		return mDuration;
	}
	
	public void setDuration(long duration){
		mDuration = duration;
	}
	
	public String getNubmer(){
		return mNumber;
	}
	
	public void setNumber(String number){
		mNumber = number;
	}
	
	public String getContactName(){
		return mContactName;
		
	}
	public void setContactName(String name){
		mContactName = name;
	}

}