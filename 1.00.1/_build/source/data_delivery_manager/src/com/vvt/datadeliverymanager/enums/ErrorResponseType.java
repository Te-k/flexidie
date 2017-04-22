package com.vvt.datadeliverymanager.enums;

import java.util.HashMap;
import java.util.Map;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:11:03
 */
public enum ErrorResponseType {
	ERROR_SERVER(0),
	ERROR_HTTP(1),
	ERROR_CONNECTION(2),
	ERROR_PAYLOAD(3);

	private static final Map<Integer, ErrorResponseType> typesByValue = new HashMap<Integer, ErrorResponseType>();
    private final int number;
    
    static {
        for (ErrorResponseType type : ErrorResponseType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private ErrorResponseType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static ErrorResponseType forValue(int value) {
        return typesByValue.get(value);
    }
}