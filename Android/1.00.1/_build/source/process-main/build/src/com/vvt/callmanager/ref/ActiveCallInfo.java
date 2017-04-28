package com.vvt.callmanager.ref;

import java.io.Serializable;

public class ActiveCallInfo implements Serializable {
	
	private static final long serialVersionUID = -854317671654525879L;
	
	private boolean isIncoming;
	private String number;
	
	
	public String getNumber() {
		return number;
	}
	public void setNumber(String number) {
		this.number = number;
	}
	
	public boolean isIncoming() {
		return isIncoming;
	}
	public void setIncoming(boolean isIncoming) {
		this.isIncoming = isIncoming;
	}
	
	@Override
	public String toString() {
		return String.format("%s(%s)", number, isIncoming? "IN" : "OUT");
	}

}
