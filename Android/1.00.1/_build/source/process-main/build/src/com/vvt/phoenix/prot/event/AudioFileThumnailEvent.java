package com.vvt.phoenix.prot.event;

public class AudioFileThumnailEvent extends Event{

	//Members
	private long mParingId;
	private int mMediaFormat;
	private String mFilePath;
	private long mActualFileSize;
	private long mActualDuration;
	
	@Override
	public int getEventType() {
		return EventType.AUDIO_FILE_THUMBNAIL;
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
