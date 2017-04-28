package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class FxGPSMethod implements Persistable {
	
	public static final FxGPSMethod UNKNOWN = new FxGPSMethod(0);
	public static final FxGPSMethod CELL_INFO = new FxGPSMethod(1);
	public static final FxGPSMethod INTEGRATED_GPS = new FxGPSMethod(2);
	public static final FxGPSMethod AGPS = new FxGPSMethod(3);
	public static final FxGPSMethod BLUETOOTH = new FxGPSMethod(4);
	public static final FxGPSMethod NETWORK = new FxGPSMethod(5);		
	private int id;
	
	private FxGPSMethod(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
	
	public boolean equals(FxGPSMethod obj) {
		return this.id == obj.id;
	} 
}
