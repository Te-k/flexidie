package com.vvt.events;

import java.util.Date;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:10:59
 */
public class FxAudioFileThumnailEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private byte mAudioData[];
	private int mActualFileSize;
	private int mActualDuration;
	private String m_ActualFullPath;
 	
 	@Override
	public FxEventType getEventType(){
		return FxEventType.AUDIO_FILE_THUMBNAIL;
	}
	
	public long getParingId(){
		return mParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void setParingId(long paringId){
		mParingId= paringId;
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

	public int getActualFileSize(){
		return mActualFileSize;
	}

	/**
	 * 
	 * @param actualFileSize    actualFileSize
	 */
	public void setActualFileSize(int actualFileSize){
		mActualFileSize = actualFileSize;
	}

	public int getActualDuration(){
		return mActualDuration;
	}

	/**
	 * 
	 * @param actualDuration    actualDuration
	 */
	public void setActualDuration(int actualDuration){
		mActualDuration = actualDuration;
	}
	
	public String getActualFullPath() {
		return m_ActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.m_ActualFullPath = actualFullPath;
	}


	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxAudioFileThumnailEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", ParingId =").append(mParingId);
		
		if(mAudioData != null) 
			builder.append(", AudioData Size=").append(mAudioData.length);
		else
			builder.append(", AudioData Size=").append("0");
			
		builder.append(", Format =").append(mFormat);
		builder.append(", Size =").append(mActualFileSize);
		builder.append(", Duration =").append(mActualDuration);
		
		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss";
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));
				
		return builder.append(" }").toString();
	}
}