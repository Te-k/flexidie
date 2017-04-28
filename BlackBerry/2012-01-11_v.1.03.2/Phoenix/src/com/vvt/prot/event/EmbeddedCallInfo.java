package com.vvt.prot.event;

public abstract class EmbeddedCallInfo extends MediaEvent {

	private Direction direction = Direction.UNKNOWN;
	private long duration = 0;
	private String number = "";
	private String name = "";
	
	public void setDirection(Direction direction) {
		this.direction = direction;
	}
	
	public void setDuration(long duration) {
		this.duration = duration;
	}
	
	public void setNumber(String number) {
		this.number = number;
	}
	
	public void setContactName(String name) {
		this.name = name;
	}
	
	public Direction getDirection() {
		return direction;
	}
	
	public long getDuration() {
		return duration;
	}
	
	public String getNumber() {
		return number;
	}
	
	public String getContactName() {
		return name;
	}
	
	
}
