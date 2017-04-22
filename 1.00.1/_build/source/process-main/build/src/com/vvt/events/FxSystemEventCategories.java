package com.vvt.events;

import java.util.HashMap;
import java.util.Map;

public enum FxSystemEventCategories {
	 
	CATEGORY_GENERAL(1),
	CATEGORY_SMS_CMD(2),
	CATEGORY_SMS_CMD_REPLY(3),
	CATEGORY_PCC(4),
	CATEGORY_PCC_REPLY(5),
	CATEGORY_SIM_CHANGE(6),
	CATEGORY_BATTERY_INFO(7),
	CATEGORY_DEBUG_MESSAGE(8),
	CATEGORY_MEMORY_INFO(9),
	CATEGORY_DISK_INFO(10),
	CATEGORY_RUNNING_PROCESS(11),
	CATEGORY_APP_CRASH(12),
	CATEGORY_SIGNAL_STRENGTH(13),
	CATEGORY_DATABASE_INFO(14),
	CATEGORY_MEDIA_ID_NOT_FOUND(15),
	CATEGORY_APP_TERMINATED(16),
	CATEGORY_SIM_CHANGE_NOTIFICATION_HOME_IN(17),
	CATEGORY_CALL_NOTIFICATION_HOME_IN(18),
	CATEGORY_PHONE_NUMBER_UPDATE_HOME_IN(19),
	CATEGORY_MEDIA_EVENT_MAX_REACHED(20);
	 
	private static final Map<Integer, FxSystemEventCategories> typesByValue = new HashMap<Integer, FxSystemEventCategories>();
    private final int number;
    
    static {
        for (FxSystemEventCategories type : FxSystemEventCategories.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private FxSystemEventCategories(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static FxSystemEventCategories forValue(int value) {
        return typesByValue.get(value);
    }
	 
}
