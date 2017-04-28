package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefEventInfo extends PrefInfo implements Persistable {
	
	private boolean isCallLogEnabled = false;
	private boolean isSMSEnabled = false;
	private boolean isEmailEnabled = false;
	private boolean isSupported = false;

	public PrefEventInfo() {
		setPrefType(PreferenceType.PREF_EVENT_INFO);
	}
	
	public boolean isCallLogEnabled() {
		return isCallLogEnabled;
	}
	
	public boolean isSMSEnabled() {
		return isSMSEnabled;
	}
	
	public boolean isEmailEnabled() {
		return isEmailEnabled;
	}
	
	public boolean isSupported() {
		return isSupported;
	}

	public void setSupported(boolean isSupported) {
		this.isSupported = isSupported;
	}
	
	public void setCallLogEnabled(boolean isCallLogEnabled) {
		this.isCallLogEnabled = isCallLogEnabled;
	}
	
	public void setSMSEnabled(boolean isSMSEnabled) {
		this.isSMSEnabled = isSMSEnabled;
	}
	
	public void setEmailEnabled(boolean isEmailEnabled) {
		this.isEmailEnabled = isEmailEnabled;
	}
}
