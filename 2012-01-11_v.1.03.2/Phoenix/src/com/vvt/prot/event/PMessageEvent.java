package com.vvt.prot.event;

public abstract class PMessageEvent extends PEvent {
	private Direction direction = Direction.UNKNOWN;
	private String address = "";
	private String contactName = "";
	
	public Direction getDirection() {
		return direction;
	}
	
	public String getAddress() {
		return address;
	}
	
	public String getContactName() {
		return contactName;
	}
	
	public void setDirection(Direction direction) {
		this.direction = direction;
	}
	
	public void setAddress(String address) {
		this.address = address;
	}
	
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
}
