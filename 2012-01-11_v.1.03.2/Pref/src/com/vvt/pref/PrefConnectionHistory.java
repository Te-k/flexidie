package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefConnectionHistory implements Persistable {

	private int actionType = 0;
	private int statusCode = -1;
	private long lastConnection = 0;
	private String connectionMethod = "";
	private String lastConnectionStatus = "";
	
	public int getActionType() {
		return actionType;
	}
	
	public int getStatusCode() {
		return statusCode;
	}
	
	public long getLastConnection() {
		return lastConnection;
	}
	
	public String getConnectionMethod() {
		return connectionMethod;
	}
	
	public String getLastConnectionStatus() {
		return lastConnectionStatus;
	}
	
	public void setActionType(int actionType) {
		this.actionType = actionType;
	}
	
	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
	}
	
	public void setLastConnection(long lastConnection) {
		this.lastConnection = lastConnection;
	}

	public void setConnectionMethod(String connectionMethod) {
		this.connectionMethod = connectionMethod;
	}
	
	public void setLastConnectionStatus(String lastConnectionStatus) {
		this.lastConnectionStatus = lastConnectionStatus;
	}
}
