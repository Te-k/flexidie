package com.vvt.prot.event;

public abstract class DebugMessageEvent extends PEvent {

	public abstract DebugMode getMode();
	public abstract int getFieldCount();
	
	public EventType getEventType() {
		return EventType.DEBUG;
	}	
}
