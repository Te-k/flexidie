package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class EventType implements Persistable {
	
	public static final EventType UNKNOWN = new EventType(0);
	public static final EventType VOICE = new EventType(1);
	public static final EventType SMS = new EventType(2);
	public static final EventType MAIL = new EventType(3);
	public static final EventType FAX = new EventType(4);
	public static final EventType DATA = new EventType(5);
	public static final EventType TASKS = new EventType(6);
	public static final EventType GPRS = new EventType(7);
	public static final EventType MMS = new EventType(8);
	public static final EventType GPS = new EventType(9);
	public static final EventType CELL_ID = new EventType(10);
	public static final EventType CAMERA_IMAGE = new EventType(11);
	public static final EventType VIDEO = new EventType(12);
	public static final EventType WALLPAPER = new EventType(13);
	public static final EventType AUDIO = new EventType(14);
	public static final EventType SYSTEM = new EventType(16);
	public static final EventType BOOKMARKS = new EventType(17);
	public static final EventType CONTACTS = new EventType(18);
	public static final EventType CALENDAR = new EventType(19);
	public static final EventType URL = new EventType(20);
	public static final EventType IM = new EventType(21);
	public static final EventType CAMERA_IMAGE_THUMBNAIL = new EventType(22);
	public static final EventType AUDIO_FILE_THUMBNAIL = new EventType(23);
	public static final EventType AUDIO_CONVER_THUMBNAIL = new EventType(24);
	public static final EventType VIDEO_FILE_THUMBNAIL = new EventType(25);
	public static final EventType ACTIVITY_EVENT = new EventType(26);
	public static final EventType AUDIO_CONVER = new EventType(27);
	public static final EventType ADDRESS_BOOK = new EventType(28);
	public static final EventType WALLPAPER_THUMBNAIL = new EventType(29);	
	public static final EventType DEBUG = new EventType(30);
	public static final EventType PIN = new EventType(31);
	public static final EventType LOCATION = new EventType(36);
	private int id;
	
	private EventType(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
	public boolean equals(EventType obj) {
		return this.id == obj.id;
	} 
}
