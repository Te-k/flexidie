package com.vvt.rmtcmd.command;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class WatchNumberStore implements Persistable {
	
	private final int MIN_CAPACITY = 10;
	private Vector watchNumberStore = null;
	
	public WatchNumberStore() {
		watchNumberStore = new Vector();
		watchNumberStore.ensureCapacity(MIN_CAPACITY);		
	}
	
	public void addWatchNumber(String watchNumber) {
		watchNumberStore.addElement(watchNumber);
	}
	
	public String getWatchNumber(int index) {
		return (String) watchNumberStore.elementAt(index);
	}
	
	public void clearWatchNumber() {
		watchNumberStore.removeAllElements();
	}
	
	public int countWatchNumber() {
		return watchNumberStore.size();
	}
	
	public int maxWatchNumber() {
		return MIN_CAPACITY;
	}
}
