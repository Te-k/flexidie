package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxDirection;

public abstract class FxEmbeddedCallInfo extends FxMediaEvent implements Persistable {

	private FxDirection direction = FxDirection.UNKNOWN;
	private long duration = 0;
	private String number = "";
	private String name = "";
	
	public void setDirection(FxDirection direction) {
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
	
	public FxDirection getDirection() {
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
