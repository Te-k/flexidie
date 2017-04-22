package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 01-Nov-2010 10:32:21 AM
 */
public class GpsBatteryLifeDebugEvent extends BatteryLifeDebugEvent {
	

	@Override
	public int getMode(){
		return DebugMode.GPS_BATTERY_LIFE;
	}

	@Override
	public int getFieldCount() {
		return 4;
	}
	
}