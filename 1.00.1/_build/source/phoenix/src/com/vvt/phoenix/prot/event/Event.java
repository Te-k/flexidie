package com.vvt.phoenix.prot.event;


/**
 * @author Tanakharn
 * @version 1.0
 * @created 31-May-2010 11:04:46 AM
 */
public abstract class Event{

	private int mId;
	private String mTime;
	
	//Constructor
	public Event(){
		mId = 0;
		mTime = null; 
	}

	public abstract int getEventType();
	
	public int getEventId(){
		return mId;
	}
	public void setEventId(int id){
		mId = id;
	}

	//return time in format YYYY-MM-DD HH:mm:ss
	public String getEventTime(){
		return mTime;
	}

	//set time in format YYYY-MM-DD HH:mm:ss
	public void setEventTime(String time){
		mTime = time;
	}

}