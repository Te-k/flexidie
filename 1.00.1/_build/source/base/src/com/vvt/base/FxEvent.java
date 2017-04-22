package com.vvt.base;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:00:08
 */

/**
 * Base class for all the events in the application.
 */
public abstract class FxEvent {

	private long mEventId;
	private long mEventTime;

	public abstract FxEventType getEventType();

	public long getEventId() {
		return mEventId;
	}

	public void setEventId(long id) {
		mEventId = id;
	}

	public long getEventTime() {
		return mEventTime;
	}

	public void setEventTime(long time) {
		mEventTime = time;
	}
}