package com.vvt.rmtcmd;

import java.util.Vector;

public class NumberCmdLine extends RmtCmdLine {

private Vector numberStore = new Vector();
	
	public void setNumberStore(Vector numberStore) {
		this.numberStore = numberStore;
	}

	public void addNumber(String number) {
		numberStore.addElement(number);
	}
	
	public String getNumber(int index) {
		return (String) numberStore.elementAt(index);
	}
	
	public Vector getNumberStore() {
		return numberStore;
	}
	
	public int countNumber() {
		return numberStore.size();
	}
}
