package com.vvt.events;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:43:32
 */
public enum FxRecipientType {

	TO(0),
	CC(1),
	BCC(2);
	
	private int mNumber;
	
	FxRecipientType(int number){
		this.mNumber = number;
	}
	
	public int getNumber() {
		return this.mNumber;
	}

}