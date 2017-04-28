package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 15-Mar-2011 11:09:54 AM
 */
public class PanicStatus extends Event {

	private int mStatus = 1;
	
	@Override
	public int getEventType(){
		return EventType.PANIC_STATUS;
	}
	
	public int getPanicStatus(){
		return mStatus;
	}
	
	public void setStartPanic(){
		mStatus = 1;
	}
	
	public void setEndPanic(){
		mStatus = 2;
	}

}