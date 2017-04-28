package com.vvt.data_delivery_manager.testsfunctional;

import java.util.HashMap;
import java.util.Map;


public enum TestType {
	SIMPLE_ACTIVATE(0), 
	LICENSE_EXPIRED(1),
	LICENSE_NOT_FOUND(2),
	LICENSE_DISABLE(3),
	REPEAT_ACTIVATE(4),
	LICENSE_DUPLICATE(5),
	
	DEACTIVATION(6),
	
	HEARTBEAT(7),
	
	PANIC_STATUS_SUCCESS(8),
	PANIC_STATUS_FAIL(9),
	
	ADDRESS_BOOK_SEND(10),
	ADDRESS_BOOK_GET(11),
	
	GET_TIME(12),
	
	THUMB_NAIL(13),
	ACTUAL_MEDIA(14);
	
	private static final Map<Integer, TestType> typesByValue = new HashMap<Integer, TestType>();
    private final int number;
    
    static {
        for (TestType type : TestType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private TestType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static TestType forValue(int value) {
        return typesByValue.get(value);
    }

}

