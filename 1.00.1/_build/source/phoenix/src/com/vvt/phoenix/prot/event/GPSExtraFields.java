package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 01-Jun-2010 6:34:51 PM
 * @deprecated
 */
public enum GPSExtraFields {
	SPEED(0),
	HEADING(1),
	ALTITUDE(2),
	PROVIDER(10),
	HOR_ACCURACY(50),
	VER_ACCURACY(51),
	HEAD_ACCURACY(52),
	SPEED_ACCURACY(53);
	
	private final int mId;
	GPSExtraFields(int id){
		mId = id;
	}
	
	public int getID(){
		return mId;
	}
}