package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 01-Nov-2010 3:53:07 PM
 */
public abstract class BatteryLifeDebugEvent extends DebugMessageEvent {

	private String mBatteryBefore;
	private String mBatteryAfter;
	private String mStartTime;
	private String mEndTime;

	public abstract int getMode();

	public abstract int getFieldCount();

	public String getBatteryBefore(){
		return mBatteryBefore;
	}

	/**
	 * 
	 * @param before
	 */
	public void setBatteryBefore(String before){
		mBatteryBefore = before;
	}

	public String getBatteryAfter(){	
		return mBatteryAfter;
	}

	/**
	 * 
	 * @param after
	 */
	public void setBatteryAfter(String after){
		mBatteryAfter = after;
	}

	public String getStartTime(){
		return mStartTime;
	}

	/**
	 * 
	 * @param time
	 */
	public void setStartTime(String time){
		mStartTime = time;
	}

	public String getEndTime(){
		return mEndTime;
	}

	/**
	 * 
	 * @param time
	 */
	public void setEndTime(String time){
		mEndTime = time;
	}

}