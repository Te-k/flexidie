package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefPIN extends PrefInfo implements Persistable {
	
	private boolean supported = false;
	private boolean enabled = false;
	
	public PrefPIN() {
		setPrefType(PreferenceType.PREF_PIN);
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
