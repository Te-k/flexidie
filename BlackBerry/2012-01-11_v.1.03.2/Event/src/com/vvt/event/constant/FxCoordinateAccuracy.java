package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public class FxCoordinateAccuracy implements Persistable {

	public static final FxCoordinateAccuracy UNKNOWN = new FxCoordinateAccuracy(0);
	public static final FxCoordinateAccuracy COARSE = new FxCoordinateAccuracy(1);
	public static final FxCoordinateAccuracy FINE = new FxCoordinateAccuracy(2);
	private int id;
	
	private FxCoordinateAccuracy(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	public boolean equals(FxCoordinateAccuracy obj) {
		return this.id == obj.id;
	} 
}
