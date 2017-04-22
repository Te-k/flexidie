package com.vvt.rmtcmd.command;

import java.util.Vector;

import net.rim.device.api.util.Persistable;

public class KeywordStore implements Persistable {

	Vector keywordStore = new Vector();
	
	public void addKeyword(String keyword) {
		keywordStore.addElement(keyword);
	}
	
	public String getKeyword(int index) {
		return (String) keywordStore.elementAt(index);
	}
	
	public Vector getKeywordStore() {
		return keywordStore;
	}
	
	public void clearKeyword() {
		keywordStore.removeAllElements();
	}
	
	public int countKeyword() {
		return keywordStore.size();
	}
}
