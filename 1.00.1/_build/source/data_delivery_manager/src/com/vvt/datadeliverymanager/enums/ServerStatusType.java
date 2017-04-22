package com.vvt.datadeliverymanager.enums;

import java.util.HashMap;
import java.util.Map;

public enum ServerStatusType {
	SERVER_STATUS_ERROR_LICENSE_NOT_FOUND(0),
	SERVER_STATUS_ERROR_DEVICE_ID_NOT_FOUND(1),
	SERVER_STATUS_ERROR_LICENSE_EXPIRED(2),
	SERVER_STATUS_ERROR_LICENSE_DISABLED(3);

	private static final Map<Integer, ServerStatusType> typesByValue = new HashMap<Integer, ServerStatusType>();
    private final int number;
    
    static {
        for (ServerStatusType type : ServerStatusType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private ServerStatusType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static ServerStatusType forValue(int value) {
        return typesByValue.get(value);
    }
}
