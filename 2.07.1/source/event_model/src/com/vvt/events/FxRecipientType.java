package com.vvt.events;

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