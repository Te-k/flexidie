package com.vvt.pref;

import com.vvt.gpsc.GPSOption;
import net.rim.device.api.util.Persistable;

public class PrefGPS extends PrefInfo implements Persistable {
	
	private boolean isEnabled = false;
	private boolean isSupported = false;
	private int warningPosition = 0;
	private GPSOption gpsOption = null;
	
	public PrefGPS() {
		setPrefType(PreferenceType.PREF_GPS);
	}
	
	public GPSOption getGpsOption() {
		return gpsOption;
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
	
	public void setGpsOption(GPSOption gpsOption) {
		this.gpsOption = gpsOption;
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
