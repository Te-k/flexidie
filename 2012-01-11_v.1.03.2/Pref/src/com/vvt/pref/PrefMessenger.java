package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefMessenger extends PrefInfo implements Persistable {

	private boolean supported = false;
	private boolean bbmEnabled = false;
	
	public PrefMessenger() {
		setPrefType(PreferenceType.PREF_IM);
	}
	
	public boolean isBBMEnabled() {
		return bbmEnabled;
	}
	
	public boolean isSupported() {
		return supported;
	}
	
	public void setBBMEnabled(boolean bbmEnabled) {
		this.bbmEnabled = bbmEnabled;
	}

	public void setSupported(boolean supported) {
		this.supported = supported;
	}
}
