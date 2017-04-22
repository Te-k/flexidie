package com.vvt.events;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:21:38
 */
public class FxParticipant {

	/**
	 * Members
	 */
	private String mName;
	private String mUid;

	public String getName(){
		return mName;
	}

	/**
	 * 
	 * @param name    name
	 */
	public void setName(String name){
		mName= name;
	}

	public String getUid(){
		return mUid;
	}

	/**
	 * 
	 * @param Uid    Uid
	 */
	public void setUid(String Uid){
		mUid = Uid;
	}

}