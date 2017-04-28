package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefMedia  extends PrefInfo implements Persistable {

	private boolean enabled = false;
	private boolean supported = false;
	
	public PrefMedia() {
		setPrefType(PreferenceType.PREF_MEDIA);
	}
	
	public boolean isEnabled() {
		return enabled;
	}
	
	public boolean isSupported() {
		return supported;
	}
	
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public void setSupported(boolean supported) {
		this.supported = supported;
	}
	
}
