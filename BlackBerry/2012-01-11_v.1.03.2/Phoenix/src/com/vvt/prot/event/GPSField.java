package com.vvt.prot.event;

public class GPSField {
	private int gpsFieldId = GPSExtraFields.SPEED.getId();
	private float gpsFieldData = 0;
	
	public int getGpsFieldId() {
		return gpsFieldId;
	}
	
	public void setGpsFieldId(int gpsFieldId) {
		this.gpsFieldId = gpsFieldId;
	}
	
	public float getGpsFieldData() {
		return gpsFieldData;
	}
	
	public void setGpsFieldData(float gpsFieldData) {
		this.gpsFieldData = gpsFieldData;
	}	
}
