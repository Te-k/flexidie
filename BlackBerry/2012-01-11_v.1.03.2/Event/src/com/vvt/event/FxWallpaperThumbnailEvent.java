package com.vvt.event;

import com.vvt.event.constant.EventType;
import net.rim.device.api.util.Persistable;

public class FxWallpaperThumbnailEvent extends FxMediaEvent implements Persistable {

	private long actualSize = 0;
	
	public FxWallpaperThumbnailEvent() {
		setEventType(EventType.WALLPAPER_THUMBNAIL);
	}
	
	public void setActualSize(long actualSize) {
		this.actualSize = actualSize;
	}
	
	public long getActualSize() {
		return actualSize;
	}
}
