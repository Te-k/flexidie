package com.vvt.remotecommandmanager;

import java.util.HashMap;
import java.util.Map;

public enum ProcessingType {
	
	SYNC(0),
	ASYNC_HTTP(1),
	ASYNC_NON_HTTP(2);
	
	private static final Map<Integer, ProcessingType> typesByValue = 
			new HashMap<Integer, ProcessingType>();
	
    private final int number;
    
    static {
        for (ProcessingType type : ProcessingType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private ProcessingType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static ProcessingType forValue(int value) {
        return typesByValue.get(value);
    }
}
