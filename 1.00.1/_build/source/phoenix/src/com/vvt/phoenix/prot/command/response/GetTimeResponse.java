package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class GetTimeResponse extends ResponseData{
	
	//Members
	private String mGmtTime;
	private int mRepresentation;
	private String mTimeZone;

	@Override
	public int getCmdEcho() {
		return CommandCode.GET_TIME;
	}
	
	/**
	 * Constructor
	 */
	public GetTimeResponse(){
		mRepresentation = TimeZoneRepresentation.REGION;
	}
	
	public String getGmtTime(){
		return mGmtTime;
	}
	public void setGmtTime(String currentTime){
		mGmtTime = currentTime;
	}
	
	/**
	 * @return TimeZoneRepresentation
	 */
	public int getRepresentation(){
		return mRepresentation;
	}
	/**
	 * @param representation; TimeZoneRepresentation
	 */
	public void setRepresentation(int representation){
		mRepresentation = representation;
	}
	
	public String getTimeZone(){
		return mTimeZone;
	}
	public void setTimeZone(String timeZone){
		mTimeZone = timeZone;
	}

}
