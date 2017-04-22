package com.vvt.prot.event;

import com.vvt.prot.CommandCode;

public abstract class PEvent {

	private int eventId;
	private String eventTime; // YYYY-MM-DD HH:mm:ss (H is 0-23) UTF8 (19 Bytes)
	public abstract EventType getEventType();
	
	public String getEventTime() {
		return eventTime;
	}
	
	public void setEventId(int eventId) {
		this.eventId = eventId;
	}
	
	public int getEventId() {
		return eventId;
	}

	public void setEventTime(String eventTime) {
		this.eventTime = eventTime;
	}
	
	//@Override
	public CommandCode getCmd() {
		return CommandCode.SEND_EVENTS;
	}
}