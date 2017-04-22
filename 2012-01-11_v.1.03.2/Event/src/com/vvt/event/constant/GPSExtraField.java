package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class GPSExtraField implements Persistable {
	
	public static final GPSExtraField SPEED = new GPSExtraField(0);
	public static final GPSExtraField HEADING = new GPSExtraField(1);
	public static final GPSExtraField ALTITUDE = new GPSExtraField(2);
	public static final GPSExtraField PROVIDER = new GPSExtraField(10);
	public static final GPSExtraField HOR_ACCURACY = new GPSExtraField(50);
	public static final GPSExtraField VER_ACCURACY = new GPSExtraField(51);
	public static final GPSExtraField HEAD_ACCURACY = new GPSExtraField(52);
	public static final GPSExtraField SPEED_ACCURACY = new GPSExtraField(53);
	private int id;
	
	private GPSExtraField(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
