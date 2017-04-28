package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

public class VideoFileThumbnailEvent extends Event{

	//Members
	private long mParingId;
	private int mMediaFormat;
	private String mFilePath;
	private ArrayList<Thumbnail> mThumbnailList;
	private long mActualFileSize;
	private long mActualDuration;
	
	public VideoFileThumbnailEvent(){
		mThumbnailList = new ArrayList<Thumbnail>();
	}
	
	@Override
	public int getEventType() {
		return EventType.VIDEO_FILE_THUMBNAIL;
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
	 * @param format from MediaType
	 */
	public void setMediaFormat(int format) {
		this.mMediaFormat = format;
	}

	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}

	public int getImagesCount(){
		return mThumbnailList.size();
	}
	
	public Thumbnail getThumbnail(int index) {
		return mThumbnailList.get(index);
	}

	public void addThumbnail(Thumbnail thumbnail) {
		mThumbnailList.add(thumbnail);
	}

	public long getActualFileSize() {
		return mActualFileSize;
	}

	public void setActualFileSize(long actualFileSize) {
		this.mActualFileSize = actualFileSize;
	}

	public long getActualDuration() {
		return mActualDuration;
	}

	public void setActualDuration(long actualDuration) {
		this.mActualDuration = actualDuration;
	}

	

}
