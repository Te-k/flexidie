package com.vvt.gpsc;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class GPSOption implements Persistable {
	
	private int interval = 0; // In second.
	private int timeout = -1; // In second.
	private Vector gpsMethodStore = new Vector();
	
	public int getTimeout() {
		return timeout;
	}

	public int getInterval() {
		return interval;
	}
	
	public void setTimeout(int timeout) {
		this.timeout = timeout;
	}
	
	public void setInterval(int interval) {
		this.interval = interval;
	}
	
	
	public void addGPSMethod(GPSMethod gpsMethod) {
		if (!isGPSMethodExisted(gpsMethod)) {
			gpsMethodStore.addElement(gpsMethod);
		}
	}
	
	public void removeGPSMethod(GPSMethod gpsMethod) {
		if (isGPSMethodExisted(gpsMethod)) {
			gpsMethodStore.removeElement(gpsMethod);
		}
	}

	public void resetGPSMethod() {
		gpsMethodStore.removeAllElements();
	}
	
	public int numberOfGPSMethod() {
		return gpsMethodStore.size();
	}
	
	public GPSMethod getGPSMethod(int index) {
		return (GPSMethod)gpsMethodStore.elementAt(index);
	}
	
	private boolean isGPSMethodExisted(GPSMethod gpsMethod) {
		boolean isExisted = false;
		for (int i = 0; i < gpsMethodStore.size(); i++) {
			GPSMethod method = (GPSMethod)gpsMethodStore.elementAt(i);
			if (method.getMethod().getId() == gpsMethod.getMethod().getId()) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
