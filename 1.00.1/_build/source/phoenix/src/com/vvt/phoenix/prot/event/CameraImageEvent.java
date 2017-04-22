package com.vvt.phoenix.prot.event;

public class CameraImageEvent extends Event{
	
	//Members
	private long mParingId;
	private int mMediaFormat;
	private GeoTag mGeo;
	private String mFileName;
	private String mFilePath;
	
	@Override
	public int getEventType() {
		return EventType.CAMERA_IMAGE;
	}

	public long getParingId() {
		return mParingId;
	}

	public void setParingId(long paringId) {
		mParingId = paringId;
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
		mGeo = geo;
	}

	public String getFileName() {
		return mFileName;
	}

	public void setFileName(String fileName) {
		mFileName = fileName;
	}

	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}	

}
