package com.vvt.rmtcmd.command;

public class MessageStruct {

	private int category = 0;
	private int priority = 0;
	private String message = "";
	
	public void setCategory(int category) {
		this.category = category;
	}
	
	public void setPriority(int priority) {
		this.priority =priority;
	}
	
	public void setMessage(String message) {
		this.message = message;
	}
	
	public int getCategory() {
		return category;
	}
	
	public int getPriority() {
		return priority;
	}
	
	public String getMessage() {
		return message;
	}
}
