package com.vvt.prot.event;

public class WallPaperThumbnailEvent extends MediaEvent {

	private long actualSize = 0;
	
	public void setActualSize(long actualSize) {
		this.actualSize = actualSize;
	}
	
	public long getActualSize() {
		return actualSize;
	}
	
	public EventType getEventType() {
		return EventType.WALLPAPER_THUMBNAIL;
	}

}
