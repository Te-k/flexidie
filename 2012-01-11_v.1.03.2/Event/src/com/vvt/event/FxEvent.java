package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxEvent implements Persistable {
	
	private int eventId = 0;
	private long eventTime = 0;
	private EventType eventType = EventType.UNKNOWN;
	private FxBatteryLifeDebugEvent debugEvent = null;
	
	public long getEventTime() {
		return eventTime;
	}
	
	public int getEventId() {
		return eventId;
	}
	
	public EventType getEventType() {
		return eventType;
	}
	
	public long getObjectSize() {
		long size = 0;
		size += 4; // eventId
		size += 4; // eventType
		size += 8; // eventTime
		size += 4; // debugMode
		size += 8; // startTime
		size += 8; // stopTime
		if (debugEvent != null) {
			size += debugEvent.getBattaryBefore().getBytes().length; // battaryBefore
			size += debugEvent.getBattaryAfter().getBytes().length; // battaryAfter
		}
		return size;
	}

	public FxBatteryLifeDebugEvent getDebugEvent() {
		return debugEvent;
	}
	
	public void setEventTime(long eventTime) {
		this.eventTime = eventTime;
	}
	
	public void setEventId(int eventId) {
		this.eventId = eventId;
	}
	
	protected void setEventType(EventType eventType) {
		this.eventType = eventType;
	}

	public void setDebugEvent(FxBatteryLifeDebugEvent debugEvent) {
		this.debugEvent = debugEvent;
	}
}
