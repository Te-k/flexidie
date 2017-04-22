package com.vvt.prot.event;

public class CallLogEvent extends PMessageEvent {
	private int duration = 0;

	public int getDuration() {
		return duration;
	}
	
	public void setDuration(int duration) {
		this.duration = duration;
	}

	public EventType getEventType() {
		return EventType.VOICE;
	}	
}