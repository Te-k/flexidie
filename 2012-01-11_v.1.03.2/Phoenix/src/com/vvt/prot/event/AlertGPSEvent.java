package com.vvt.prot.event;

public class AlertGPSEvent extends PanicEvent {

	public EventType getEventType() {
		return EventType.ALERT_GPS;
	}
}
