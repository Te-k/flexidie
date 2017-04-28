package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxLogType;

public class FxSystemEvent extends FxEvent implements Persistable {
	
	private FxLogType logType = FxLogType.UNKNOWN;
	private FxDirection direction = FxDirection.UNKNOWN;
	private FxCategory category = FxCategory.UNKNOWN;
	private String systemMessage = "";
	
	public FxSystemEvent() {
		setEventType(EventType.SYSTEM);
	}
	
	public FxLogType getLogType() {
		return logType;
	}
	
	public FxDirection getDirection() {
		return direction;
	}
	
	public String getSystemMessage() {
		return systemMessage;
	}

	public FxCategory getCategory() {
		return category;
	}
	
	public void setLogType(FxLogType logType) {
		this.logType = logType;
	}
	
	public void setDirection(FxDirection direction) {
		this.direction = direction;
	}
	
	public void setSystemMessage(String systemMessage) {
		this.systemMessage = systemMessage;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 1; // logType
		size += 1; // direction
		size += systemMessage.getBytes().length; // systemMessage
		return size;
	}

	public void setCategory(FxCategory category) {
		this.category = category;
	}
}
