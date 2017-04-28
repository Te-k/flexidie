package com.vvt.events;

public enum FxCallingModuleType {

	UNKNOWN(0),
	CORE_TRIGGER(1),
	PANIC(2),
	ALERT(3);
	
	private int mNumber;
	
	FxCallingModuleType(int number){
		this.mNumber = number;
	}
	
	public int getNumber(){
		return mNumber;
	}
}
