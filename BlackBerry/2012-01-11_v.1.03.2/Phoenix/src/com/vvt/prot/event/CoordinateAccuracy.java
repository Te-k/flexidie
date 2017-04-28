package com.vvt.prot.event;

public class CoordinateAccuracy {

	public static final CoordinateAccuracy UNKNOWN = new CoordinateAccuracy(0);
	public static final CoordinateAccuracy COARSE = new CoordinateAccuracy(1);
	public static final CoordinateAccuracy FINE = new CoordinateAccuracy(2);
	private int id;
	
	private CoordinateAccuracy(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
}
