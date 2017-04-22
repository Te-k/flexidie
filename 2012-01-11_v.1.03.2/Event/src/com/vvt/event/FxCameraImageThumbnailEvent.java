package com.vvt.event;

import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxMediaTypes;
import net.rim.device.api.util.Persistable;

public class FxCameraImageThumbnailEvent extends FxGeoTag implements Persistable {
	
	private long actualSize = 0;
	private FxMediaTypes format = FxMediaTypes.UNKNOWN;
	
	public FxCameraImageThumbnailEvent() {
		setEventType(EventType.CAMERA_IMAGE_THUMBNAIL);
	}
	
	public void setActualSize(long actualSize) {
		this.actualSize = actualSize;
	}
	
	public long getActualSize() {
		return actualSize;
	}
	
	public void setFormat(FxMediaTypes format) {
		this.format = format;
	}
	
	public FxMediaTypes getFormat() {
		return format;
	}	
}
