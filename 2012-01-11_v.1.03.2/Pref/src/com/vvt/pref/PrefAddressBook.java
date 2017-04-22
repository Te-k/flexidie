package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefAddressBook extends PrefInfo implements Persistable {
	
	private boolean isSupported = false;
	private boolean isEnabled = false;
	
	public PrefAddressBook() {
		setPrefType(PreferenceType.PREF_ADDRESS_BOOK);
	}
	
	public boolean isSupported() {
		return isSupported;
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}

	public void setSupported(boolean isSupported) {
		this.isSupported = isSupported;
	}

	public void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}
}
