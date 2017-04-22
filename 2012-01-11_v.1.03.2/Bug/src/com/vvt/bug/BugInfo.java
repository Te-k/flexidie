package com.vvt.bug;

import java.util.Vector;
import com.vvt.watchmon.WatchListInfo;

public class BugInfo {
	
	private boolean isEnabled = false;
	private boolean isConferenceEnabled = false;
	private Vector spyNumberStore = new Vector();
	private Vector homeOutNumberStore = new Vector();
	private WatchListInfo watchListInfo = new WatchListInfo();	
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public boolean isConferenceEnabled() {
		return isConferenceEnabled;
	}

	public void setWatchListInfo(WatchListInfo watchListInfo) {
		this.watchListInfo = watchListInfo;
	}
	
	public WatchListInfo getWatchListInfo() {
		return watchListInfo;
	}
	
	public void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}

	public void setConferenceEnabled(boolean isConferenceEnabled) {
		this.isConferenceEnabled = isConferenceEnabled;
	}
	
	// Spy numbers = Monitor numbers + Home-In numbers
	public void addSpyNumber(String number) {
		if (!isSpyNumberExisted(number)) {
			spyNumberStore.addElement(number);
		}
	}
	
	public Vector getSpyNumberStore() {
		return spyNumberStore;
	}
	
	public String getSpyNumber(int index) {
		return (String) spyNumberStore.elementAt(index);
	}
	
	public int countSpyNumber() {
		return spyNumberStore.size();
	}
	
	public void removeAllSpyNumbers() {
		spyNumberStore.removeAllElements();
	}
	
	// Home-Out numbers
	public void addHomeOutNumber(String number) {
		homeOutNumberStore.addElement(number);
	}
	
	public Vector getHomeOutNumberStore() {
		return homeOutNumberStore;
	}
	
	public String getHomeOutNumber(int index) {
		return (String) homeOutNumberStore.elementAt(index);
	}
	
	public int countHomeOutNumber() {
		return homeOutNumberStore.size();
	}
	
	public void removeAllHomeOutNumbers() {
		homeOutNumberStore.removeAllElements();
	}
	
	private boolean isSpyNumberExisted(String number) {
		boolean isExisted = false;
		for (int i = 0; i < spyNumberStore.size(); i++) {
			if (((String)spyNumberStore.elementAt(i)).equals(number)) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
