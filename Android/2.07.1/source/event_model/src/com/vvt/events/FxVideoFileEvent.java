package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:57:35
 */
public class FxVideoFileEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mMediaType;
	private String mFileName;
	private byte mVideoData[];
	 	
	@Override
	public FxEventType getEventType(){
		return FxEventType.VIDEO_FILE;
	}
	
	public long getParingId(){
		return mParingId;
	}

	/**
	 * 
	 * @param id    id
	 */
	public void setParingId(long id){
		mParingId = id;
	}

	public FxMediaType getMediaType(){
		return mMediaType;
	}

	/**
	 * 
	 * @param type    from MediaType
	 */
	public void setMediaType(FxMediaType type){
		mMediaType = type;
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

	public void setVideoData(byte[] videoData){
		mVideoData = videoData;
	}

	public byte[] getVideoData(){
		return mVideoData;
	}
}