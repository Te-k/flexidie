package com.vvt.sms;


public class SmsData {
	
	private String time;
	private boolean isIncoming;
	private String phonenumber;
	private String data;
	private String contactName;
	
	public String getTime() {
		return time;
	}
	public void setTime(String time) {
		this.time = time;
	}
	public boolean isIncoming() {
		return isIncoming;
	}
	public void setIncoming(boolean isIncoming) {
		this.isIncoming = isIncoming;
	}
	public String getPhonenumber() {
		return phonenumber;
	}
	public void setPhonenumber(String phonenumber) {
		this.phonenumber = phonenumber;
	}
	public String getData() {
		return data;
	}
	public void setData(String data) {
		this.data = data;
	}
	public String getContactName() {
		return contactName;
	}
	public void setContactName(String contactName) {
		this.contactName = contactName;
	}
	
	@Override
	public String toString() {
		return String.format(
				"SMS: number=%s, contactName=%s, isIncoming: %s, time=%s, data=%s", 
				phonenumber, contactName, isIncoming, time, data);
	}
}
