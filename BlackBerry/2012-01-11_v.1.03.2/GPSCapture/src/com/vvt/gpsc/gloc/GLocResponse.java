package com.vvt.gpsc.gloc;

public class GLocResponse {
	
//	public static int LOCATION_UNDEFINE = -1000;
	public static int LOCATION_UNDEFINE = 0;
	private double latitude = LOCATION_UNDEFINE;
	private double longitude = LOCATION_UNDEFINE;
	private long time = 0;
	private int err = 0; // Error value when parsing response data.
	private GLocRequest request = null;
	
	public GLocResponse(GLocRequest request) {
		this.request = request;
	}
	
	public double getLatitude() {
		return latitude;
	}
	
	public double getLongitude() {
		return longitude;
	}
	
	public long getTime() {
		return time;
	}

	public GLocRequest getRequest() {
		return request;
	}
	
	public double getErr() {
		return err;
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public void setTime(long time) {
		this.time = time;
	}
	
	public void setErr(int err) {
		this.err = err;
	}
}
