package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefCellInfo extends PrefInfo implements Persistable {
	
	private boolean isEnabled = false;
	private boolean isSupported = false;
	private int interval = 0; // In second.
	private int warningPosition = 0;
	
	public PrefCellInfo() {
		setPrefType(PreferenceType.PREF_CELL_INFO);
	}
	
	public int getInterval() {
		return interval;
	}
	
	public int getWarningPosition() {
		return warningPosition;
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public boolean isSupported() {
		return isSupported;
	}
	
	public void setInterval(int interval) {
		this.interval = interval;
	}

	public void setSupported(boolean isSupported) {
		this.isSupported = isSupported;
	}
	
	public void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}
	
	public void setWarningPosition(int warningPosition) {
		this.warningPosition = warningPosition;
	}
}
