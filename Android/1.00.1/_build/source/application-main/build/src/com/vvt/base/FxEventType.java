package com.vvt.base;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:54:05
 */
public enum FxEventType {

	UNKNOWN(0),
	
	/**
	 * Communication Events
	 */
	CALL_LOG(1),
	SMS(2),
	MAIL(3),
	MMS(8),
	
	/**
	 * check IM value later
	 */
	IM(21),
	PIN_MESSAGE(31),
	
	/**
	 * Panic and Alert Events
	 */
	PANIC_GPS(32),
	PANIC_IMAGE(33),
	PANIC_STATUS(34),
	ALERT_GPS(35),
	
	/**
	 * Media Thumbnail Events
	 * Note: Please update any modification to 'isThumbnail()' as well.
	 */
	WALLPAPER_THUMBNAIL(29),
	CAMERA_IMAGE_THUMBNAIL(22),
	AUDIO_CONVERSATION_THUMBNAIL(24),
	AUDIO_FILE_THUMBNAIL(23),
	VIDEO_FILE_THUMBNAIL(25),
	
	/**
	 * Actual Media Events
	 */
	WALLPAPER(13),
	CAMERA_IMAGE(11),
	AUDIO_CONVERSATION(27),
	AUDIO_FILE(14),
	VIDEO_FILE(12),
	DELETED_FILE(15),
	
	/**
	 * Positioning Events
	 */
	LOCATION(9),
	CELL_INFO(10),
	
	/**
	 * System Events
	 */
	SYSTEM(16),
	DEBUG_EVENT(30),
	
	/**
	 * Setting Events
	 */
	SETTINGS(37),
	
	/**
	 * Other Events
	 */
	ADDRESS_BOOK(28),
	SMS_REMOTE_COMMAND(40),
	NETWORK_REMOTE_COMMAND(41),
	SIM_CHANGE(42),
	ACTUAL_MEDIA_DAO(43),
	EVENT_BASE(44);
	
	
	/*private int number;

    FxEventType(int number) {
       this.number = number;
    }

    public int getNumber() {
        return number;
    }*/
    
    private static final Map<Integer, FxEventType> typesByValue = new HashMap<Integer, FxEventType>();
    private final int number;
    
    static {
        for (FxEventType type : FxEventType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private FxEventType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static FxEventType forValue(int value) {
        return typesByValue.get(value);
    }
    
    public static boolean isThumbnail(FxEventType type) {
    	return type == WALLPAPER_THUMBNAIL || 
    			type == CAMERA_IMAGE_THUMBNAIL ||
    			type ==  AUDIO_CONVERSATION_THUMBNAIL ||
    			type == AUDIO_FILE_THUMBNAIL || 
    			type == VIDEO_FILE_THUMBNAIL;
    }

}
	