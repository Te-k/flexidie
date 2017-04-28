package com.fx.android.common.events.location;

import com.fx.dalvik.util.TelephonyUtils.NetworkOperator;

import android.telephony.CellLocation;

public class CellInfo {

	private CellLocation cellLocation;
	
	private NetworkOperator networkOperator;
	
	private int counter;
	
	private long time;
	
	private String debugMessage = null;
	
	public CellLocation getCellLocation() {
		return cellLocation;
	}

	public void setCellLocation(CellLocation cellLocation) {
		this.cellLocation = cellLocation;
	}

	public NetworkOperator getNetworkOperator() {
		return networkOperator;
	}

	public void setNetworkOperator(NetworkOperator networkOperator) {
		this.networkOperator = networkOperator;
	}

	public int getCounter() {
		return counter;
	}

	public void setCounter(int counter) {
		this.counter = counter;
	}
	
	public long getTime() {
		return time;
	}

	public void setTime(long aTime) {
		time = aTime;
	}
	
	public String getDebugMessage() {
		return debugMessage;
	}
	
	public void setDebugMessage(String aDebugMessage) {
		debugMessage = aDebugMessage;
	}
}
