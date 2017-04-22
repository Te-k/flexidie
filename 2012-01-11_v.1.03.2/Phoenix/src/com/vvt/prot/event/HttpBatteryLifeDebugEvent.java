package com.vvt.prot.event;

public class HttpBatteryLifeDebugEvent extends BatteryLifeDebugEvent {

	private String payloadSize = null;
	private int fieldCount = 5;
	
	public void setPayloadSize(String payloadSize) {
		this.payloadSize = payloadSize;
	}
	
	public String getPayloadSize() {
		return payloadSize;
	}

	public int getFieldCount() {
		return fieldCount;
	}
	
	public DebugMode getMode() {
		return DebugMode.HTTP;
	}	
}
