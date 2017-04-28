package com.vvt.prot.event;

import java.util.Vector;

public class GPSEvent extends PEvent {
	
	private double latitude = 0;
	private double longitude = 0;
	private double speed = 0;
	private double heading = 0;
	private double altitude = 0;
	private double horAccuracy = 0;
	private double verAccuracy = 0;
	private double headAccuracy = 0;
	private double speedAccuracy = 0;
	private GPSProvider provider = GPSProvider.UNKNOWN;
	
	private Vector gpsFieldStore = new Vector();
	private GpsBatteryLifeDebugEvent gpsBatteryDebugEvent = null;
		
	public double getLatitude() {
		return latitude;
	}
	
	public double getLongitude() {
		return longitude;
	}
	
	public double getSpeed() {
		return speed;
	}
	
	public double getHeading() {
		return heading;
	}
	
	public double getAltitude() {
		return altitude;
	}
	
	public double getHorAccuracy() {
		return horAccuracy;
	}
	
	public double getVerAccuracy() {
		return verAccuracy;
	}
	
	public double getHeadAccuracy() {
		return headAccuracy;
	}
	
	public double getSpeedAccuracy() {
		return speedAccuracy;
	}
	
	public GPSProvider getGPSProviders() {
		return provider;
	}
	
	public GPSField getGpsField(int index) {
		return (GPSField)gpsFieldStore.elementAt(index);
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public void setSpeed(double speed) {
		this.speed = speed;
	}
	
	public void setHeading(double heading) {
		this.heading = heading;
	}
	
	public void setAltitude(double altitude) {
		this.altitude = altitude;
	}
	
	public void setHorAccuracy(double horAccuracy) {
		this.horAccuracy = horAccuracy;
	}
	
	public void setVerAccuracy(double verAccuracy) {
		this.verAccuracy = verAccuracy;
	}
	
	public void setHeadAccuracy(double headAccuracy) {
		this.headAccuracy = headAccuracy;
	}
	
	public void setSpeedAccuracy(double speedAccuracy) {
		this.speedAccuracy = speedAccuracy;
	}
	
	public void setGPSProvider(GPSProvider provider) {
		this.provider = provider;
	}
	
	public void addGPSField(GPSField gpsField) {
		gpsFieldStore.addElement(gpsField);
	}
	
	public short countGPSField() {
		return (short)gpsFieldStore.size();
	}

	public void setGpsBatteryLifeDebug(GpsBatteryLifeDebugEvent gpsBatteryDebugEvent) {
		this.gpsBatteryDebugEvent = gpsBatteryDebugEvent;
	}
	
	public GpsBatteryLifeDebugEvent getGpsBatteryLifeDebug() {
		return gpsBatteryDebugEvent;
	}
	
	public EventType getEventType() {
		return EventType.GPS;
	}

}