package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxDebugMode;

public class FxHttpBatteryLifeDebugEvent extends FxBatteryLifeDebugEvent implements Persistable {
	
	private String payloadSize = "";
	
	public String getPayloadSize() {
		return payloadSize;
	}
	
	public void setPayloadSize(String payloadSize) {
		this.payloadSize = payloadSize;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += payloadSize.getBytes().length; // payloadSize
		return size;
	}
	
	// FxBatteryLifeDebugEvent
	public FxDebugMode getMode() {
		return FxDebugMode.HTTP;
	}
}
