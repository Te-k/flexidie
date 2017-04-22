package com.vvt.phoenix.prot.event;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 7:08:43 PM
 */
public class SystemEvent extends Event {
	
	private int mCategory;
	private int mDirection;
	private String mData;

	//Constructor
	public SystemEvent(){
	}
	
	public int getEventType(){
		return EventType.SYSTEM;
	}

	public int getCategory(){
		return mCategory;
	}
	/**
	 * @param type from SystemEventCategories 
	 */
	public void setCategory(int type){
		mCategory = type;
	}

	//public byte getDirection(){
	public int getDirection(){
		return mDirection;
	}
	//public void setDirection(byte direction){
	/**
	 * @param direction from EventDirection
	 */
	public void setDirection(int direction){
		mDirection = direction;
	}

	public String getSystemMessage(){
		return mData;
	}
	public void setSystemMessage(String message){
		mData = message;
	}	

}