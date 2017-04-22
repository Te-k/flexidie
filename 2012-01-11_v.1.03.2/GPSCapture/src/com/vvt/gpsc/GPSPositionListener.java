package com.vvt.gpsc;

public interface GPSPositionListener {
	
	public void locationUpdate(double latitude, double longitude);
	
	public void locationError();
	
}
