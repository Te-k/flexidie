package com.vvt.phoenix.prot.event;

public class AudioConversationEvent extends Event {

	//Members
	private long mParingId;
	private int mFormat;
	private EmbededCallInfo mEmbededCallInfo;
	private String mFileName;
	private String mFilePath;
	
	@Override
	public int getEventType() {
		return EventType.AUDIO_CONVERSATION;
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
