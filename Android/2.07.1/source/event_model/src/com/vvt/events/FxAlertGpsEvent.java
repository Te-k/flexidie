package com.vvt.events;

import com.vvt.base.FxEventType;

public class FxAlertGpsEvent extends FxLocationBase{

	
	@Override
	public FxEventType getEventType(){
		return FxEventType.ALERT_GPS;
	}
}
