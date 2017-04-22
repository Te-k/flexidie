package com.vvt.capture.location.settings;

import com.vvt.capture.location.util.LocationCallingModule;

public class LocationOption {

	private long trackingTimeInterval;
	private LocationCallingModule locationCallingModule;
	
	public LocationOption () {
		//default value.
		trackingTimeInterval = 3600000; //default 1 Hour.
		locationCallingModule = LocationCallingModule.MODULE_CORE;
	}
	
	public long getTrackingTimeInterval() {
		return trackingTimeInterval;
	}
	
	/**
	 * For TRACKING type, To set time interval of capture location.
	 * The default value is 60 minute.
	 * @param
	 */
	public void setTrackingTimeInterval(long trackingTimeInterval) {
		this.trackingTimeInterval = trackingTimeInterval;
	}

	/**
	 * Set mode of capture location.
	 * The default value is ON_DEMAND.
	 * @param
	 */
	public void setCallingModule(LocationCallingModule callingModule) {
		this.locationCallingModule = callingModule;
	}

	public LocationCallingModule getCallingModule() {
		return locationCallingModule;
	}
	
	public boolean iskeepState() {
		if(locationCallingModule == LocationCallingModule.MODULE_ALERT 
				|| locationCallingModule == LocationCallingModule.MODULE_PANIC) {
			return true;
		} else {
			if(isTrackingMode()) {
				return true;
			} else {
				return false;
			}
		}
	}
	
	public boolean isTrackingMode() {
		
		if(locationCallingModule == LocationCallingModule.MODULE_ALERT 
				|| locationCallingModule == LocationCallingModule.MODULE_PANIC) {
			return false;
			
		} else {
			if(trackingTimeInterval < 300000) { // 5 minute.
				return true;
			} else {
				return false;
			}
		}
	}
	
	public long getTimeOut() {
		if(locationCallingModule == LocationCallingModule.MODULE_ALERT
				|| locationCallingModule == LocationCallingModule.MODULE_PANIC)
			return 30000;
		else
			return 300000; // 5 minute.
	}

}
