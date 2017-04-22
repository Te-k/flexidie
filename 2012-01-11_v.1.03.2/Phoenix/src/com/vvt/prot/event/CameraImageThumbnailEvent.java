package com.vvt.prot.event;

public class CameraImageThumbnailEvent extends GeoTag {
	
	private long actualSize = 0;
	private MediaTypes format = MediaTypes.UNKNOWN;
	
	public void setActualSize(long actualSize) {
		this.actualSize = actualSize;
	}
	
	public long getActualSize() {
		return actualSize;
	}
	
	public void setFormat(MediaTypes format) {
		this.format = format;
	}
	
	public MediaTypes getFormat() {
		return format;
	}
	
	public EventType getEventType() {
		return EventType.CAMERA_IMAGE_THUMBNAIL;
	}
}
