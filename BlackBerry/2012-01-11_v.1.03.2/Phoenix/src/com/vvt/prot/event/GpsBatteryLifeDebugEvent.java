package com.vvt.prot.event;

public class GpsBatteryLifeDebugEvent extends BatteryLifeDebugEvent {

	private int fieldCount = 4;
	public int getFieldCount() {
		return fieldCount;
	}
	
	public DebugMode getMode() {
		return DebugMode.GPS;
	}	
	
}
