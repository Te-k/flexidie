package com.vvt.mediamon.info;

import com.vvt.event.constant.FxMediaTypes;
import net.rim.device.api.util.Persistable;

//import com.vvt.event.constant.FxMediaTypes;

public abstract class MediaInfo implements Persistable {

	public abstract MediaInfoType getMediaInfoType();
	private FxMediaTypes mediaType = FxMediaTypes.UNKNOWN;
	private String actualPath = null;
	private String actualName = null;
	private String thumbPath = null;
	private int paringId = 0;
	
	public void setActualPath(String actualPath) {
		this.actualPath = actualPath;
	}
	
	public void setActualName(String actualName) {
		this.actualName = actualName;
	}
	
	public void setThumbPath(String thumbPath) {
		this.thumbPath = thumbPath;
	}

	public void setFxMediaTypes(FxMediaTypes mediaType) {
		this.mediaType = mediaType;
	}
	
	public void setParingId(int paringId) {
		this.paringId = paringId;
	}
	
	public String getActualPath() {
		return actualPath;
	}
	
	public String getActualName() {
		return actualName;
	}
	
	public String getThumbPath() {
		return thumbPath;
	}
	
	public FxMediaTypes getFxMediaTypes() {
		return mediaType;
	}
	
	public int getParingId() {
		return paringId;
	}
		
}
