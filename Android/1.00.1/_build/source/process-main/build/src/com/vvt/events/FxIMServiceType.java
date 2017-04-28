package com.vvt.events;

import java.util.HashMap;
import java.util.Map;

public enum FxIMServiceType {
	IM_WHATSAPP("WhatsApp"),
	IM_GTALK("Google Talk"),
	IM_FACEBOOK("Facebook"),
	IM_SKYPE("Skype");
	
	private static final Map<String, FxIMServiceType> typesByValue = 
			new HashMap<String, FxIMServiceType>();
	
    private final String mValue;
    
    static {
        for (FxIMServiceType type : FxIMServiceType.values()) {
            typesByValue.put(type.mValue, type);
        }
    }

    private FxIMServiceType(String value) {
        this.mValue = value;
    }

    public String getValue() {
        return mValue;
    }
    
    public static FxIMServiceType forValue(String value) {
        return typesByValue.get(value);
    };
}
