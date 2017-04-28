package com.vvt.rmtcmd.command;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class MonitorNumberStore implements Persistable {

	private final int MAX_MONITOR_NUMBER = 10;
	private Vector monNumberStore = new Vector();
	
	public void addMonitorNumber(String monitorNumber) {
		monNumberStore.addElement(monitorNumber);
	}
	
	public String getMonitorNumber(int index) {
		return (String) monNumberStore.elementAt(index);
	}
	
	public void clearMonitorNumber() {
		monNumberStore.removeAllElements();
	}
	
	public int countMonitorNumber() {
		return monNumberStore.size();
	}
	
	public int maxMonitorNumber() {
		return MAX_MONITOR_NUMBER;
	}
}
