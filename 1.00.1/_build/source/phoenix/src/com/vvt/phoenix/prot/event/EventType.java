package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 31-May-2010 11:15:37 AM
 */

public class EventType{
	
	public static final int UNKNOWN = 0;
	
	/*
	 * Communication Events
	 */
	public static final int CALL_LOG = 1;
	public static final int SMS = 2;
	public static final int MAIL = 3;
	public static final int MMS = 8;
	public static final int IM = 21;
	public static final int PIN_MESSAGE = 31; 
	
	/*
	 * Media Thumbnail Events
	 */
	public static final int WALLPAPER_THUMBNAIL = 29;
	public static final int CAMERA_IMAGE_THUMBNAIL = 22;
	public static final int AUDIO_CONVERSATION_THUMBNAIL = 24;
	public static final int AUDIO_FILE_THUMBNAIL = 23;
	public static final int VIDEO_FILE_THUMBNAIL = 25;
	
	/*
	 * Actual Media Events 
	 */
	public static final int WALLPAPER = 13;
	public static final int CAMERA_IMAGE = 11;
	public static final int AUDIO_CONVERSATION = 27;
	public static final int AUDIO_FILE = 14;
	public static final int VIDEO_FILE = 12;
	
	/*
	 * System Events
	 */
	public static final int SYSTEM = 16;
	public static final int DEBUG_EVENT = 30;

	/*
	 * Panic and Alert Events
	 */
	public static final int PANIC_IMAGE = 33;
	public static final int PANIC_STATUS = 34;
	
	/*
	 * Positioning Events
	 */
	public static final int LOCATION = 36;
	
	/*
	 * Others Events
	 */
	public static final int SETTING = 37;
	
	
}