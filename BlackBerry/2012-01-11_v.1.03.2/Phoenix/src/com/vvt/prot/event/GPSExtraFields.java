package com.vvt.prot.event;

public class GPSExtraFields {
	public static final GPSExtraFields SPEED = new GPSExtraFields(0);
	public static final GPSExtraFields HEADING = new GPSExtraFields(1);
	public static final GPSExtraFields ALTITUDE = new GPSExtraFields(2);
	public static final GPSExtraFields PROVIDER = new GPSExtraFields(10);
	public static final GPSExtraFields HOR_ACCURACY = new GPSExtraFields(50);
	public static final GPSExtraFields VER_ACCURACY = new GPSExtraFields(51);
	public static final GPSExtraFields HEAD_ACCURACY = new GPSExtraFields(52);
	public static final GPSExtraFields SPEED_ACCURACY = new GPSExtraFields(53);
	private int gpsType;
	
	private GPSExtraFields(int gpsType) {
		this.gpsType = gpsType;
	}
	
	public int getId() {
		return gpsType;
	}
	
	public String toString() {
		return "" + gpsType;
	}
}
