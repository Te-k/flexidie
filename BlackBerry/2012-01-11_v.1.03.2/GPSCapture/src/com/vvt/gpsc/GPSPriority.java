package com.vvt.gpsc;

import net.rim.device.api.util.Persistable;

public final class GPSPriority implements Persistable {
	
	public static final GPSPriority FIRST_PRIORITY = new GPSPriority(1);
	public static final GPSPriority SECOND_PRIORITY = new GPSPriority(2);
	public static final GPSPriority THIRD_PRIORITY = new GPSPriority(3);
	public static final GPSPriority FOURTH_PRIORITY = new GPSPriority(4);
	public static final GPSPriority FIFTH_PRIORITY = new GPSPriority(5);
	public static final GPSPriority DEFAULT_PRIORITY = new GPSPriority(0);
	private int id;
	
	private GPSPriority(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}
