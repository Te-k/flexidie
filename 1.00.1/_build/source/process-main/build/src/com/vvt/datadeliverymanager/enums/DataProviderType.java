package com.vvt.datadeliverymanager.enums;

import java.util.HashMap;
import java.util.Map;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 12:28:50
 */
public enum DataProviderType {
	DATA_PROVIDER_TYPE_NONE (0),
	DATA_PROVIDER_TYPE_PANIC (1),
	DATA_PROVIDER_TYPE_SYSTEM (2),
	DATA_PROVIDER_TYPE_ALL_REGULAR (3),
	DATA_PROVIDER_TYPE_ACTUAL_MEDIA (4),
	DATA_PROVIDER_TYPE_SETTINGS (5);

	private static final Map<Integer, DataProviderType> typesByValue = 
			new HashMap<Integer, DataProviderType>();
	
    private final int number;
    
    static {
        for (DataProviderType type : DataProviderType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private DataProviderType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static DataProviderType forValue(int value) {
        return typesByValue.get(value);
    }
}