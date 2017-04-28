package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxDirection;

public class FxMessageEvent extends FxEvent implements Persistable {
	
	private FxDirection direction = FxDirection.UNKNOWN;
	private String address = "";
	private String contactName = "";
	
	public FxDirection getDirection() {
		return direction;
	}
	
	public String getAddress() {
		return address;
	}
	
	public String getContactName() {
		return contactName;
	}
	
	public void setDirection(FxDirection direction) {
		this.direction = direction;
	}
	
	public void setAddress(String address) {
		this.address = address;
	}
	
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 4; // direction
		size += address.getBytes().length; // address
		size += contactName.getBytes().length; // contactName
		return size;
	}
}
