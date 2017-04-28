package com.vvt.events;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 12:23:42
 */
public enum FxEventDirection {

	UNKNOWN(0),
	IN(1),
	OUT(2),
	MISSED_CALL(3),
	LOCAL_IM(4);
	
	private static final Map<Integer, FxEventDirection> typesByValue = new HashMap<Integer, FxEventDirection>();
    private final int number;
    
    static {
        for (FxEventDirection type : FxEventDirection.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private FxEventDirection(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static FxEventDirection forValue(int value) {
        return typesByValue.get(value);
    }
}