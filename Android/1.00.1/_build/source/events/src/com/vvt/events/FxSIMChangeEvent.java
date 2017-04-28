package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:44:53
 */
public class FxSIMChangeEvent extends FxEvent {

	private String mSubscriberId;
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.SIM_CHANGE;
	}
	
	public String getSubscriberId(){
		return mSubscriberId;
	}

	public void setSubscriberId(String subscriberId){
		mSubscriberId = subscriberId;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		
		builder.append("FxSIMChangeEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", SubscriberId =").append(mSubscriberId);
		return builder.append(" }").toString();
	}
}