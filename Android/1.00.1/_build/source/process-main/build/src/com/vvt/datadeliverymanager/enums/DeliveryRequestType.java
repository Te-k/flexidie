package com.vvt.datadeliverymanager.enums;

import java.util.HashMap;
import java.util.Map;

 
/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:11:07
 */
public enum DeliveryRequestType {
	REQUEST_TYPE_NEW(0),
	REQUEST_TYPE_PERSISTED(1);
	
	private static final Map<Integer, DeliveryRequestType> typesByValue = new HashMap<Integer, DeliveryRequestType>();
    private final int number;
    
    static {
        for (DeliveryRequestType type : DeliveryRequestType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private DeliveryRequestType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static DeliveryRequestType forValue(int value) {
        return typesByValue.get(value);
    }
}