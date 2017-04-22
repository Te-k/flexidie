package com.vvt.phoenix.prot.event;

public class VideoFileEvent extends Event{

	//Members
	private long mParingId;
	private int mMediaFormat;
	private String mFileName;
	private String mFilePath;
	
	@Override
	public int getEventType() {
		return EventType.VIDEO_FILE;
	}
	
	public long getParingId(){
		return mParingId;
	}
	public void setParingId(long id){
		mParingId = id;
	}
	
	public int getMediaFormat(){
		return mMediaFormat;
	}
	/**
	 * @param format from MediaType
	 */
	public void setMediaFormat(int format){
		mMediaFormat = format;
	}
	
	public String getFileName(){
		return mFileName;
	}
	public void setFileName(String fileName){
		mFileName = fileName;
	}
	
	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}
	
}
