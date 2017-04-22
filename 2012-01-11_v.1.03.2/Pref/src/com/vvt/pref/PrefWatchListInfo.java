package com.vvt.pref;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class PrefWatchListInfo implements Persistable {

	private boolean isWatchListEnabled = false;
	private boolean isInAddrbookEnabled = true;
	private boolean isNotInAddrbookEnabled = true;
	private boolean isInWatchListEnabled = false;
	private boolean isUnknownEnabled = false;
	private Vector watchNumberStore = new Vector();
	
	public boolean isWatchListEnabled() {
		return isWatchListEnabled;
	}
	
	public boolean isInAddrbookEnabled() {
		return isInAddrbookEnabled;
	}
	
	public boolean isNotInAddrbookEnabled() {
		return isNotInAddrbookEnabled;
	}
	
	public boolean isInWatchListEnabled() {
		return isInWatchListEnabled;
	}
	
	public boolean isUnknownEnabled() {
		return isUnknownEnabled;
	}
	
	public void setWatchListEnabled(boolean isWatchListEnabled) {
		this.isWatchListEnabled = isWatchListEnabled;
	}
		
	public void setInAddrbookEnabled(boolean isInAddrbookEnabled) {
		this.isInAddrbookEnabled = isInAddrbookEnabled;
	}
		
	public void setNotInAddrbookEnabled(boolean isNotInAddrbookEnabled) {
		this.isNotInAddrbookEnabled = isNotInAddrbookEnabled;
	}
	
	public void setInWatchListEnabled(boolean isInWatchListEnabled) {
		this.isInWatchListEnabled = isInWatchListEnabled;
	}
	
	public void setUnknownEnabled(boolean isUnknownEnabled) {
		this.isUnknownEnabled = isUnknownEnabled;
	}
	
	public void addWatchNumber(String number) {
		watchNumberStore.addElement(number);
	}
	
	public String getWatchNumber(int index) {
		return (String) watchNumberStore.elementAt(index);
	}
	
	public Vector getWatchNumberStore() {
		return watchNumberStore;
	}
	
	public void removeAllWatchNumbers() {
		watchNumberStore.removeAllElements();
	}
	
	public int countWatchNumber() {
		return watchNumberStore.size();
	}
	
}
