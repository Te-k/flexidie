package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefSystem extends PrefInfo implements Persistable {

	private boolean simChangeEnabled = false;
	private boolean supported = false;
	
	public PrefSystem() {
		setPrefType(PreferenceType.PREF_SYSTEM);
	}
	
	public boolean isSIMChangeEnabled() {
		return simChangeEnabled;
	}
	
	public boolean isSupported() {
		return supported;
	}

	public void setSupported(boolean isSupported) {
		this.supported = isSupported;
	}
	
	public void setSIMChangeEnabled(boolean isEnabled) {
		this.simChangeEnabled = isEnabled;
	}
}
