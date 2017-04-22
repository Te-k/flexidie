package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:09:48
 */
public class FxAudioFileEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private String mFileName;
	private byte mAudioData[];
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.AUDIO_FILE;
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