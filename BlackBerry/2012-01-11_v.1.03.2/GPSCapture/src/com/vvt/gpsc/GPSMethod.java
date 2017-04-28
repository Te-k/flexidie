package com.vvt.gpsc;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxGPSMethod;

public class GPSMethod implements Persistable {
	
	private GPSPriority priority = GPSPriority.DEFAULT_PRIORITY;
	private FxGPSMethod method = FxGPSMethod.UNKNOWN;
	
	public FxGPSMethod getMethod() {
		return method;
	}
	
	public GPSPriority getPriority() {
		return priority;
	}
	
	public void setMethod(FxGPSMethod method) {
		this.method = method;
	}
	
	public void setPriority(GPSPriority priority) {
		this.priority = priority;
	}
}
