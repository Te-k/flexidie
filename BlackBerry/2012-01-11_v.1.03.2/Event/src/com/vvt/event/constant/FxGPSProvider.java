package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public class FxGPSProvider implements Persistable {

	public static FxGPSProvider UNKNOWN = new FxGPSProvider(0);
	public static FxGPSProvider GOOGLE = new FxGPSProvider(1);
	public int id;
	
	private FxGPSProvider(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	public boolean equals(FxGPSProvider obj) {
		return this.id == obj.id;
	} 
}
