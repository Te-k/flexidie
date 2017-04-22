package com.daemon_bridge;

import java.io.Serializable;

public abstract class CommandResponseBase implements Serializable  {
	public final static int SUCCESS = 0;
	public static final int ERROR = -1;
	private final static long serialVersionUID = 6602770371209229180L;
	

	private int responseCode = -1;
	
	public CommandResponseBase(int responseCode) {
		this.responseCode = responseCode;
	}
	
	public void setResponseCode(int responseCode) {
		this.responseCode = responseCode;
	}
	
	public int getResponseCode() {
		return this.responseCode;
	}
}
