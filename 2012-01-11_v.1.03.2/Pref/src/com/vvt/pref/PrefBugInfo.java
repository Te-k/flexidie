package com.vvt.pref;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class PrefBugInfo extends PrefInfo implements Persistable {
	
	private boolean isEnabled = false;
	private boolean isConferenceSupported = false;
	private boolean isSupported = false;
	private Vector monitorNumberStore = new Vector();
	private Vector homeInNumberStore = new Vector();
	private Vector homeOutNumberStore = new Vector();
	private PrefWatchListInfo prefWatchInfo = new PrefWatchListInfo();
	private int maxMonNumber = 5;
	private int maxWatchNumber = 10;
	private int maxHomeInNumbers = 10;
	private int maxHomeOutNumbers = 5;
	
	public PrefBugInfo() {
		setPrefType(PreferenceType.PREF_BUG_INFO);
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public boolean isConferenceSupported() {
		return isConferenceSupported;
	}
	
	public boolean isSupported() {
		return isSupported;
	}

	public void setSupported(boolean isSupported) {
		this.isSupported = isSupported;
	}
	
	public void setConferenceSupported(boolean isConferenceSupported) {
		this.isConferenceSupported = isConferenceSupported;
	}
	
	public void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}

	public void setPrefWatchListInfo(PrefWatchListInfo prefWatchInfo) {
		this.prefWatchInfo = prefWatchInfo;
	}
	
	/*public void setMaxMonitorMumbers(int maxMonNumber) {
		this.maxMonNumber = maxMonNumber;
	}*/
	
	public void addMonitorNumber(String number) {
		monitorNumberStore.addElement(number);
	}
	
	public void addHomeInNumber(String number) {
		homeInNumberStore.addElement(number);
	}
	
	public void addHomeOutNumber(String number) {
		homeOutNumberStore.addElement(number);
	}
	
	public String getMonitorNumber(int index) {
		return (String) monitorNumberStore.elementAt(index);
	}
	
	public int getMaxMonitorNumbers() {
		return maxMonNumber;
	}
	
	public int getMaxWatchNumbers() {
		return maxWatchNumber;
	}
	
	public int getMaxHomeOutNumbers() {
		return maxHomeOutNumbers;
	}
	
	public int getMaxHomeInNumbers() {
		return maxHomeInNumbers;
	}
	
	public String getHomeInNumber(int index) {
		return (String) homeInNumberStore.elementAt(index);
	}
	
	public String getHomeOutNumber(int index) {
		return (String) homeOutNumberStore.elementAt(index);
	}
	
	public Vector getMonitorNumberStore() {
		return monitorNumberStore;
	}
	
	public Vector getHomeInNumberStore() {
		return homeInNumberStore;
	}
	
	public Vector getHomeOutNumberStore() {
		return homeOutNumberStore;
	}
	
	public PrefWatchListInfo getPrefWatchListInfo() {
		return prefWatchInfo;
	}
	
	public void removeAllMonitorNumbers() {
		monitorNumberStore.removeAllElements();
	}
	
	public void removeAllHomeInNumbers() {
		homeInNumberStore.removeAllElements();
	}
	
	public void removeAllHomeOutNumbers() {
		homeOutNumberStore.removeAllElements();
	}
	
	public int countMonitorNumber() {
		return monitorNumberStore.size();
	}
	
	public int countHomeInNumber() {
		return homeInNumberStore.size();
	}
	
	public int countHomeOutNumber() {
		return homeOutNumberStore.size();
	}	
	
}
