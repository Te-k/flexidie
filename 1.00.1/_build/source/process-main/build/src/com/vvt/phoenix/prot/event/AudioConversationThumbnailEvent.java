package com.vvt.phoenix.prot.event;

public class AudioConversationThumbnailEvent extends Event{

	//Members
	private long mParingId;
	private int mFormat;
	private EmbededCallInfo mEmbededCallInfo;
	private String mFilePath;
	private long mActualFileSize;
	private long mActualDuration;
	
	
	@Override
	public int getEventType() {
		return EventType.AUDIO_CONVERSATION_THUMBNAIL;
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

	public EmbededCallInfo getEmbededCallInfo() {
		return mEmbededCallInfo;
	}

	public void setEmbededCallInfo(EmbededCallInfo embededCallInfo) {
		this.mEmbededCallInfo = embededCallInfo;
	}
	
	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}

	public long getActualFileSize(){
		return mActualFileSize;
	}
	public void setActualFileSize(long size){
		mActualFileSize = size;
	}
	
	public long getActualDuration(){
		return mActualDuration;
	}
	public void setActualDuration(long duration){
		mActualDuration = duration;
	}
	

}
