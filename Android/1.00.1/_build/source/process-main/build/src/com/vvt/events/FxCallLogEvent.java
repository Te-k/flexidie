package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:48:28
 */
public class FxCallLogEvent extends FxEvent {

	private FxEventDirection mDirection;
	private long mDuration;
	private String mNumber;
	private String mContactName;


	@Override
	public FxEventType getEventType(){
		return FxEventType.CALL_LOG;
	}

	public FxEventDirection getDirection(){
		return mDirection;
	}

	/**
	 * @param direction from EventDirection
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

	public String getNubmer(){
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
		return mContactName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setContactName(String name){
		mContactName = name;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		
		builder.append("FxCallLogEvent {");
		
		builder.append(" EventId =").append(super.getEventId());
		
		if(getDirection() == FxEventDirection.IN) {
			builder.append(", Direction =").append("IN");
		}
		else if(getDirection() == FxEventDirection.OUT) {
			builder.append(", Direction =").append("OUT"); 
		}
		else if(getDirection() == FxEventDirection.MISSED_CALL) {
			builder.append(", Direction =").append("MISSED CALL"); 
		}
		else {
				builder.append(", Direction =").append("Invalid");
		}

		builder.append(", Duration =").append(getDuration());
		builder.append(", Nubmer =").append(getNubmer());
		builder.append(", ContactName =").append(getContactName());
		builder.append(", EventTime =").append(super.getEventTime());
		return builder.append(" }").toString();
	}

}