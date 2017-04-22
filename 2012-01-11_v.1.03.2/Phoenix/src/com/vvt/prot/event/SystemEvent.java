package com.vvt.prot.event;

public class SystemEvent extends PEvent {
	//private LogType logType = LogType.UNKNOWN;
	private Direction direction = Direction.UNKNOWN;
	private Category category = Category.UNKNOWN;
	private String systemMessage = "";
	
	/*public LogType getLogType() {
		return logType;
	}*/
	
	public Direction getDirection() {
		return direction;
	}
	
	public String getSystemMessage() {
		return systemMessage;
	}
	public Category getCategory() {
		return category;
	}
	
	/*public void setLogType(LogType logType) {
		this.logType = logType;
	}*/
	
	public void setDirection(Direction direction) {
		this.direction = direction;
	}
	
	public void setSystemMessage(String systemMessage) {
		this.systemMessage = systemMessage;
	}
	
	public void setCategory(Category category) {
		this.category = category;
	}
	
	public long lengthOfSystemMessage() {
		return systemMessage.length();
	}

	public EventType getEventType() {
		return EventType.SYSTEM_EVENT;
	}
}
