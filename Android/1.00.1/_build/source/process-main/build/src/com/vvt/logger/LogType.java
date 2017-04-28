package com.vvt.logger;

import java.util.HashMap;
import java.util.Map;


public enum LogType {
	
	ERROR (0),
	WARNING (1),
	DEBUG (2),
	INFO (3),
	VERBOSE (4);
	
	private static final Map<Integer, LogType> typesByValue = 
			new HashMap<Integer, LogType>();
	
    private final int number;
    
    static {
        for (LogType type : LogType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private LogType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static LogType forValue(int value) {
        return typesByValue.get(value);
    }
}
