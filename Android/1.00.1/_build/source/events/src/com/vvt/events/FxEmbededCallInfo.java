package com.vvt.events;


/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:27:54
 */
public class FxEmbededCallInfo {

	/**
	 * Members
	 */
	private FxEventDirection mDirection;
	private long mDuration;
	private String mNumber;
	private String mContactName;
	
	public FxEventDirection getDirection(){
		return mDirection;
	}

	/**
	 * 
	 * @param direction    direction
	 */
	public void setDirection(FxEventDirection direction){
		mDirection = direction;
	}

	public long getDuration(){
		return mDuration;
	}

	/**
	 * 
	 * @param duration    duration
	 */
	public void setDuration(long duration){
		mDuration = duration;
	}

	public String getNumber(){
		return mNumber;
	}

	/**
	 * 
	 * @param number    number
	 */
	public void setNumber(String number){
		mNumber = number;
	}	

	public String getContactName(){
		return mContactName ;
	}

	/**
	 * 
	 * @param contactName    contactName
	 */
	public void setContactName(String contactName){
		mContactName = contactName;
	}

}