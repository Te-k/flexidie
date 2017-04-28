package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxSystemEvent extends FxEvent {

	private FxSystemEventCategories logType;
	private FxEventDirection direction;
	private String message;
	
	@Override
	public FxEventType getEventType() {
		return FxEventType.SYSTEM;
	}

	public FxSystemEventCategories getLogType() {
		return logType;
	}

	public void setLogType(FxSystemEventCategories logType) {
		this.logType = logType;
	}

	public FxEventDirection getDirection() {
		return direction;
	}

	public void setDirection(FxEventDirection direction) {
		this.direction = direction;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		
		builder.append("FxSystemEvent {");
		
		builder.append(" EventId =").append(super.getEventId());
		
		if(getDirection() == FxEventDirection.IN) {
			builder.append(", Direction =").append("IN");
		}
		else if(getDirection() == FxEventDirection.OUT) {
			builder.append(", Direction =").append("OUT"); 
		}
		else if(getDirection() == FxEventDirection.MISSED_CALL) {
			builder.append(", Direction =").append("MISSED CALL"); 
		}
		else {
				builder.append(", Direction =").append("Invalid");
		}

		builder.append(", logType =").append(getLogType());
		builder.append(", message =").append(getMessage());
		builder.append(", EventTime =").append(super.getEventTime());
		return builder.append(" }").toString();
	}

}
