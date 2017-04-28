package com.vvt.phoenix.prot.event;

public class WallPaperThumbnailEvent extends Event{

	//Members
	private long mParingId;
	private int mFormat;
	private String mFilePath;
	private long mActualFileSize;
	
	@Override
	public int getEventType() {
		return EventType.WALLPAPER_THUMBNAIL;
	}
	
	public long getParingId() {
		return mParingId;
	}
	public void setParingId(long paringId) {
		this.mParingId = paringId;
	}
	
	public int getFormat() {
		return mFormat;
	}
	/**
	 * @param format from MediaType
	 */
	public void setFormat(int format) {
		this.mFormat = format;
	}
	
	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}	
	
	public long getActualFileSize() {
		return mActualFileSize;
	}
	public void setActualFileSize(long actualFileSize) {
		this.mActualFileSize = actualFileSize;
	}


}
