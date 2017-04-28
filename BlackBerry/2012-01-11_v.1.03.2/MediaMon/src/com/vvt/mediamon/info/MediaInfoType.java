package com.vvt.mediamon.info;

import net.rim.device.api.util.Persistable;

public class MediaInfoType implements Persistable {

	public static final MediaInfoType UNKNOWN = new MediaInfoType(0);
	public static final MediaInfoType IMAGE_THUMBNAIL = new MediaInfoType(1);
	public static final MediaInfoType AUDIO_THUMBNAIL = new MediaInfoType(2);
	public static final MediaInfoType VIDEO_THUMBNAIL = new MediaInfoType(3);
	private int id;
	
	private  MediaInfoType(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	public boolean equals(MediaInfoType obj) {
		return this.id == obj.id;
	}
}
