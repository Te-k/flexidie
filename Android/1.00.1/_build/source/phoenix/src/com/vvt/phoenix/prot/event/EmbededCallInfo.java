package com.vvt.phoenix.prot.event;

public class EmbededCallInfo {

	//Members
	private int mDirection;
	private long mDuration;
	private String mNumber;
	private String mContactName;
	
	public int getDirection() {
		return mDirection;
	}
	public void setDirection(int direction) {
		this.mDirection = direction;
	}
	public long getDuration() {
		return mDuration;
	}
	public void setDuration(long duration) {
		this.mDuration = duration;
	}
	public String getNumber() {
		return mNumber;
	}
	public void setNumber(String number) {
		this.mNumber = number;
	}
	public String getContactName() {
		return mContactName;
	}
	public void setContactName(String contactName) {
		this.mContactName = contactName;
	}
}
