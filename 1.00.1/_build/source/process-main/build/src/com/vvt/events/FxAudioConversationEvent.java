package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:36:55
 */
public class FxAudioConversationEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private String mFileName;
	private byte mAudioData[];
	private FxEmbededCallInfo m_EmbededCallInfo;

	@Override
	public FxEventType getEventType(){
		return FxEventType.AUDIO_CONVERSATION;
	}
 	
	public long getParingId(){
		return mParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void setParingId(long paringId){
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

	public String getFileName(){
		return mFileName;
	}

	/**
	 * 
	 * @param fileName    fileName
	 */
	public void setFileName(String fileName){
		mFileName = fileName;
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

}