package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefCameraImage extends PrefInfo implements Persistable {

	private boolean enabled = false;
	private boolean supported = false;
	private boolean firstEnabled = false;
	
	public PrefCameraImage() {
		setPrefType(PreferenceType.PREF_CAMERA_IMAGE);
	}
	
	public boolean isEnabled() {
		return enabled;
	}
	
	public boolean isFirstEnabled() {
		return firstEnabled;
	}
	
	public boolean isSupported() {
		return supported;
	}
	
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public void setFirstEnabled(boolean firstEnabled) {
		this.firstEnabled = firstEnabled;
	}
	
	public void setSupported(boolean supported) {
		this.supported = supported;
	}
}
