package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:30:00
 */
public class FxAudioConversationThumbnailEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private byte mAudioData[];
	private long mActualFileSize;
	private long mActualDuration;
	public FxEmbededCallInfo m_EmbededCallInfo;
	private String m_ActualFullPath;

	@Override
	public FxEventType getEventType(){
		return FxEventType.AUDIO_CONVERSATION_THUMBNAIL;
	}
	
	public long getParingId(){
		return mParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void mFormat(long paringId){
		mParingId = paringId;
	}

	public FxMediaType getFormat(){
		return mFormat;
	}

	/**
	 * 
	 * @param format    from MediaType
	 */
	public void setFormat(FxMediaType format){
		mFormat = format;
	}

	public FxEmbededCallInfo getEmbededCallInfo(){
		return m_EmbededCallInfo;
	}

	/**
	 * 
	 * @param embededCallInfo    embededCallInfo
	 */
	public void setEmbededCallInfo(FxEmbededCallInfo embededCallInfo){
		m_EmbededCallInfo = embededCallInfo;
	}

	/**
	 */
	public byte[] getAudioData(){
		return mAudioData;
	}

	/**
	 * 
	 * @param audioData    audioData
	 */
	public void setAudioData(byte[] audioData){
		mAudioData = audioData;
	}

	public long getActualFileSize(){
		return mActualFileSize;
	}

	/**
	 * 
	 * @param size    size
	 */
	public void setActualFileSize(long size){
		mActualFileSize = size;
	}

	public long getActualDuration(){
		return mActualDuration;
	}

	/**
	 * 
	 * @param duration    duration
	 */
	public void setActualDuration(long duration){
		mActualDuration = duration;
	}
	
	public String getActualFullPath() {
		return m_ActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.m_ActualFullPath = actualFullPath;
	}
}