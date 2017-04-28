package com.vvt.remotecommandmanager;

import java.util.HashMap;
import java.util.Map;


public enum RemoteCommandType {
	PCC(0),
	SMS_COMMAND(1);
	
	private static final Map<Integer, RemoteCommandType> typesByValue = 
			new HashMap<Integer, RemoteCommandType>();
	
    private final int number;
    
    static {
        for (RemoteCommandType type : RemoteCommandType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private RemoteCommandType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static RemoteCommandType forValue(int value) {
        return typesByValue.get(value);
    }
}
