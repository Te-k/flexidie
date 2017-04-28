package com.fx.android.common.events.location;

import android.location.Location;

public class LocationInfo {

	private Location location;
	
	private int counter;
	
	private String debugMessage = null;
	
	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}

	public int getCounter() {
		return counter;
	}

	public void setCounter(int counter) {
		this.counter = counter;
	}
	
	public String getDebugMessage() {
		return debugMessage;
	}
	
	public void setDebugMessage(String aDebugMessage) {
		debugMessage = aDebugMessage;
	}

}
