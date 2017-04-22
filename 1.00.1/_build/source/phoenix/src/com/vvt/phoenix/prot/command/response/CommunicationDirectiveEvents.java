package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

public class CommunicationDirectiveEvents {

	//Members
	//private int mCount;
	private ArrayList<Integer> mCommuEventTypeList;
	
	//Communication Event Type constants
	public static final int CALL = 1;
	public static final int SMS = 2;
	public static final int MMS = 3;
	public static final int EMAIL = 4;
	public static final int IM = 20;
	
	/**
	 * Constructor
	 */
	public CommunicationDirectiveEvents(){
		mCommuEventTypeList = new ArrayList<Integer>();
	}
	
	public int getCount(){
		//return mCount;
		return mCommuEventTypeList.size();
	}
	/*public void setCount(int count){
		mCount = count;
	}*/
	
	public int getEventType(int index){
		return mCommuEventTypeList.get(index);
	}
	public void addEventType(int eventType){
		mCommuEventTypeList.add(eventType);
	}
}
