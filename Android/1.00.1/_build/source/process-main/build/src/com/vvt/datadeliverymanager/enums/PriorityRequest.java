package com.vvt.datadeliverymanager.enums;

import java.util.HashMap;
import java.util.Map;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:11:04
 */
public enum PriorityRequest {
	PRIORITY_HIGH(6), 
	PRIORITY_NORMAL(2),
	PRIORITY_LOW(0);

	private static final Map<Integer, PriorityRequest> typesByValue = new HashMap<Integer, PriorityRequest>();
    private final int number;
    
    static {
        for (PriorityRequest type : PriorityRequest.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private PriorityRequest(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static PriorityRequest forValue(int value) {
        return typesByValue.get(value);
    }
}