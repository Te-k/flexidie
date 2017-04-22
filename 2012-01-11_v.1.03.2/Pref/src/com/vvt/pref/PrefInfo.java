package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefInfo implements Persistable {
	
	private PreferenceType prefType = PreferenceType.PREF_UNKNOWN;
	
	public PreferenceType getPrefType() {
		return prefType;
	}
	
	protected void setPrefType(PreferenceType prefType) {
		this.prefType = prefType;
	}
}