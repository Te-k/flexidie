package com.vvt.capture.location.util;

import java.util.HashMap;
import java.util.Map;

public enum LocationCallingModule {
	MODULE_CORE(0),
	MODULE_PANIC(1),
	MODULE_ALERT(2),
	MODULE_LOCATION_ON_DEMAND(3);
	
	private static final Map<Integer, LocationCallingModule> typesByValue = 
			new HashMap<Integer, LocationCallingModule>();
	
    private final int number;
    
    static {
        for (LocationCallingModule type : LocationCallingModule.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private LocationCallingModule(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static LocationCallingModule forValue(int value) {
        return typesByValue.get(value);
    }
}
