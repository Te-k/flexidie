package com.vvt.phoenix.prot.event;

public class CameraImageThumbnailEvent extends Event{

	//Members
	private long mParingId;
	private int mMediaFormat;
	private GeoTag mGeo;
	private String mFilePath;
	private long mActualSize;
	
	@Override
	public int getEventType() {
		return EventType.CAMERA_IMAGE_THUMBNAIL;
	}
	
	public long getParingId() {
		return mParingId;
	}

	public void setParingId(long paringId) {
		this.mParingId = paringId;
	}

	public int getMediaFormat() {
		return mMediaFormat;
	}

	/**
	 * @param mediaFormat from MediaType
	 */
	public void setMediaFormat(int mediaFormat) {
		this.mMediaFormat = mediaFormat;
	}

	public GeoTag getGeo() {
		return mGeo;
	}

	public void setGeo(GeoTag geo) {
		this.mGeo = geo;
	}

	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}

	public long getActualSize() {
		return mActualSize;
	}

	public void setActualSize(long actualSize) {
		this.mActualSize = actualSize;
	}

	

}
