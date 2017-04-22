package com.vvt.prot.command.response;

import java.util.Vector;

public class CommunicationDirectives {
	
	private TimeUnit timeUnit = TimeUnit.UNKNOWN;
	private Criteria criteria = new Criteria();
	private int action = 0;
	private int direction = 0;
	private Vector communicationEventTypes = new Vector();
	private String startDate = ""; // YYYY-MM-DD
	private String endDate = ""; // YYYY-MM-DD
	private String dayStartTime = ""; // HH:mm
	private String dayEndTime = ""; // HH:mm
	
	public TimeUnit getTimeUnit() {
		return timeUnit;
	}
	
	public Criteria getCriteria() {
		return criteria;
	}
	
	public int getAction() {
		return action;
	}
	
	public int getDirection() {
		return direction;
	}
	
	public CommunicationEventType getCommunicationEventTypes(int index) {
		return (CommunicationEventType) communicationEventTypes.elementAt(index);
	}
	
	public String getStartDate() {
		return startDate;
	}
	
	public String getEndDate() {
		return endDate;
	}
	
	public String getDayStartTime() {
		return dayStartTime;
	}
	
	public String getDayEndTime() {
		return dayEndTime;
	}
	
	public void setTimeUnit(TimeUnit timeUnit) {
		this.timeUnit = timeUnit;
	}
	
	public void setCriteria(Criteria criteria) {
		this.criteria = criteria;
	}
	
	public void setAction(int action) {
		this.action = action;
	}
	
	public void setDirection(int direction) {
		this.direction = direction;
	}
	
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	
	public void setDayStartTime(String dayStartTime) {
		this.dayStartTime = dayStartTime;
	}
	
	public void setDayEndTime(String dayEndTime) {
		this.dayEndTime = dayEndTime;
	}
	
	public void addCommunicationEventType(CommunicationEventType type) {
		communicationEventTypes.addElement(type);
	}
	
	public int countCommunicationEvents() {
		return communicationEventTypes.size();
	}
	
	public void removeAllCommunicationEvents() {
		communicationEventTypes.removeAllElements();
	}
}
