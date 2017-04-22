package com.vvt.prot.event;

public class GPSProvider {
	
	public static final GPSProvider UNKNOWN = new GPSProvider(0);
	public static final GPSProvider GPS = new GPSProvider(1);
	public static final GPSProvider AGPS = new GPSProvider(2);
	public static final GPSProvider NETWORK = new GPSProvider(3);
	public static final GPSProvider BLUETOOTH = new GPSProvider(4);
	public static final GPSProvider GPS_G = new GPSProvider(5);
	private int id;
	
	private GPSProvider(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	public String toString() {
		return "" + id;
	}
}
