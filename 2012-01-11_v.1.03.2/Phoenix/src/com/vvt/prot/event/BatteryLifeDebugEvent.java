package com.vvt.prot.event;

public abstract class BatteryLifeDebugEvent extends DebugMessageEvent {

	private String batteryBefore = null;
	private String batteryAfter = null;
	private String startTime = null;
	private String endTime = null;
	
	public void setBatteryBefore(String batteryBefore) {
		this.batteryBefore = batteryBefore;
	}
	
	public String getBatteryBefore() {
		return batteryBefore;
	}
	
	public void setBatteryAfter(String batteryAfter) {
		this.batteryAfter = batteryAfter;
	}
	
	public String getBatteryAfter() {
		return batteryAfter;
	}
	
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	
	public String getStartTime() {
		return startTime;
	}
	
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	
	public String getEndTime() {
		return endTime;
	}
	
	
}
