package com.vvt.calllog;


public class CallLogData {
	
	public static enum Direction { IN, OUT, MISSED };
	
	private long time;
	private String timeInitiated;
	private String timeConnected;
	private String timeTerminated;
	private Direction direction;
	private int duration;
	private String phonenumber;
	private int status;
	private String contactName;
	
	public String getTimeInitiated() {
		return timeInitiated;
	}
	public void setTimeInitiated(String timeInitiated) {
		this.timeInitiated = timeInitiated;
	}
	public String getTimeConnected() {
		return timeConnected;
	}
	public void setTimeConnected(String timeConnected) {
		this.timeConnected = timeConnected;
	}
	public String getTimeTerminated() {
		return timeTerminated;
	}
	public void setTimeTerminated(String timeTerminated) {
		this.timeTerminated = timeTerminated;
	}
	public Direction getDirection() {
		return direction;
	}
	public void setDirection(Direction direction) {
		this.direction = direction;
	}
	public int getDuration() {
		return duration;
	}
	public void setDuration(int duration) {
		this.duration = duration;
	}
	public String getPhonenumber() {
		return phonenumber;
	}
	public void setPhonenumber(String phonenumber) {
		this.phonenumber = phonenumber;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getContactName() {
		return contactName;
	}
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
	
	@Override
	public String toString() {
		return String.format("Call: number=%s, contactName=%s, time=%s", 
				phonenumber, contactName, timeInitiated);
	}
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	
}
