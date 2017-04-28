package com.vvt.event;

import net.rim.device.api.util.Persistable;

public abstract class FxBatteryLifeDebugEvent  extends FxDebugMessageEvent implements Persistable {
	
	private String battaryBefore = "";
	private String battaryAfter = "";
	private long startTime = 0;
	private long stopTime = 0;
	
	public String getBattaryBefore() {
		return battaryBefore;
	}
	
	public String getBattaryAfter() {
		return battaryAfter;
	}
	
	public long getStartTime() {
		return startTime;
	}
	
	public long getStopTime() {
		return stopTime;
	}
	
	public void setBattaryBefore(String battaryBefore) {
		this.battaryBefore = battaryBefore;
	}
	
	public void setBattaryAfter(String battaryAfter) {
		this.battaryAfter = battaryAfter;
	}
	
	public void setStartTime(long startTime) {
		this.startTime = startTime;
	}
	
	public void setStopTime(long stopTime) {
		this.stopTime = stopTime;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 8; // startTime
		size += 8; // stopTime
		size += battaryBefore.getBytes().length; // battaryBefore
		size += battaryAfter.getBytes().length; // battaryAfter
		return size;
	}
}
