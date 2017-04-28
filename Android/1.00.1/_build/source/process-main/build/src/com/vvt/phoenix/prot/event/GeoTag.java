package com.vvt.phoenix.prot.event;

public class GeoTag {

	//Members
	private double mLat;
	private double mLon;
	private double mAltitude;
	
	public double getLat() {
		return mLat;
	}
	public void setLat(double lat) {
		this.mLat = lat;
	}
	
	public double getLon() {
		return mLon;
	}
	public void setLon(double lon) {
		this.mLon = lon;
	}
	
	public double getAltitude() {
		return mAltitude;
	}
	public void setAltitude(double altitude) {
		this.mAltitude = altitude;
	}
	
}
