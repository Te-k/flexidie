package com.vvt.phoenix.prot.event;

public class AudioFileEvent extends Event{

	//Members
	private long mParingId;
	private int mMediaFormat;
	private String mFileName;
	private String mFilePath;
	
	@Override
	public int getEventType() {
		return EventType.AUDIO_FILE;
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

	public String getFileName() {
		return mFileName;
	}

	public void setFileName(String fileName) {
		this.mFileName = fileName;
	}

	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}

}
