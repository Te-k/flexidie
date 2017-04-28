package com.vvt.callmanager.ref;

import java.io.Serializable;

public class InterceptingSms implements Serializable {

	private static final long serialVersionUID = 2681337469089694646L;
	
	private String number;
	private String message;
	
	public String getNumber() {
		return number;
	}
	public void setNumber(String number) {
		this.number = number;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	
	@Override
	public String toString() {
		return String.format("%s=[%s]", number, message);
	}
	
}
