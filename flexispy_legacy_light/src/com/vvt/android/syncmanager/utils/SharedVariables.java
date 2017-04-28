package com.vvt.android.syncmanager.utils;

import android.location.Location;

public final class SharedVariables {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private Location gpsLocation;

	private Location networkLocation;
	
//------------------------------------------------------------------------------------------------------------------------
// PUBLIC API
//------------------------------------------------------------------------------------------------------------------------
	
	public Location getGpsLocation() { return gpsLocation; }

	public void setGpsLocation(Location aGPSLocation) { this.gpsLocation = aGPSLocation; }

	public Location getNetworkLocation() { return networkLocation; }

	public void setNetworkLocation(Location aNetworkLocation) { this.networkLocation = aNetworkLocation; }	
}
