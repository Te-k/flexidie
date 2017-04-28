package com.vvt.prot.event;

public abstract class GeoTag extends MediaEvent {

	private double longitude = 0;
	private double latitude = 0;
	private double altitude = 0;
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	public double getLongitude() {
		return longitude;
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude; 
	}
	
	public double getLatitude() {
		return latitude;
	}
	
	public void setAltitude(double altitude) {
		this.altitude = altitude;
	}
	
	public double getAltitude() {
		return altitude;
	}
}
