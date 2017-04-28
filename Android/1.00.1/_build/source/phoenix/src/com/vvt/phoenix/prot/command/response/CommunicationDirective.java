package com.vvt.phoenix.prot.command.response;


public class CommunicationDirective {
	
	//Members
	private int mTimeUnit;
	private CommunicationDirectiveCriteria mCriteria;
	private CommunicationDirectiveEvents mCommunicationEvents;
	private String mStartDate;
	private String mEndDate;
	private String mDayStartTime;
	private String mDayEndTime;
	private int mAction;
	private int mDirection;
	
	//Time Unit Constants
	public static final int TIME_UNIT_DAILY = 1;
	public static final int TIME_UNIT_WEEKLY = 2;
	public static final int TIME_UNIT_MONTHLY = 3;
	public static final int TIME_UNIT_YEARLY = 4;
	
	//Action constants
	public static final int ACTION_ALLOW = 1;
	public static final int ACTION_BLOCK = 2;
	
	//Direction constants
	public static final int DIRECTION_IN = 1;
	public static final int DIRECTION_OUT = 2;
	public static final int DIRECTION_ALL = 3;
	
	public int getTimeUnit(){
		return mTimeUnit;
	}
	public void setTimeUnit(int timeUnit){
		mTimeUnit = timeUnit;
	}
	
	public CommunicationDirectiveCriteria getCriteria(){
		return mCriteria;
	}
	public void setCriteria(CommunicationDirectiveCriteria criteria){
		mCriteria = criteria;
	}
	
	public CommunicationDirectiveEvents getCommunicationEvents(){
		return mCommunicationEvents;
	}
	public void setCommunicationEvents(CommunicationDirectiveEvents commuEvents){
		mCommunicationEvents = commuEvents;
	}
	
	public String getStartDate(){
		return mStartDate;
	}
	public void setStartDate(String startDate){
		mStartDate = startDate;
	}
	
	public String getEndDate(){
		return mEndDate;
	}
	public void setEndDate(String endDate){
		mEndDate = endDate;
	}
	
	public String getDayStartTime(){
		return mDayStartTime;
	}
	public void setDayStartTime(String dayStartTime){
		mDayStartTime = dayStartTime;
	}
	
	public String getDayEndTime(){
		return mDayEndTime;
	}
	public void setDayEndTime(String dayEndTime){
		mDayEndTime = dayEndTime;
	}
	
	public int getAction(){
		return mAction;
	}
	/**
	 * @param action from CommuAction
	 * 
	 */
	public void setAction(int action){
		mAction = action;
	}
	
	public int getDirection(){
		return mDirection;
	}
	/**
	 * @param direction from CommuDirection
	 */
	public void setDirection(int direction){
		mDirection = direction;
	}

}
