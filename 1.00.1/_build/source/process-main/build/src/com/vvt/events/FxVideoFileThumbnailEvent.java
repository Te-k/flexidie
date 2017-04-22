package com.vvt.events;

import java.util.ArrayList;
import java.util.Date;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:02:39
 */
public class FxVideoFileThumbnailEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private byte mVideoData[];
	private ArrayList<FxThumbnail> mThumbnailList;
	private long mActualFileSize;
	private int mActualDuration;
	private String mActualFullPath;
 	

	@Override
	public FxEventType getEventType(){
		return FxEventType.VIDEO_FILE_THUMBNAIL;
	}
	
	public FxVideoFileThumbnailEvent(){
		mThumbnailList = new ArrayList<FxThumbnail>();
	}

	public long getParingId(){
		return mParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void setParingId(long paringId){
		mParingId=  paringId;
	}

	public FxMediaType getFormat(){
		return mFormat;
	}

	/**
	 * 
	 * @param format    from MediaType
	 */
	public void setFormat(FxMediaType format){
		mFormat  = format;
	}

	public byte[] getVideoData(){
		return mVideoData;
	}

	/**
	 * 
	 * @param videoData    videoData
	 */
	public void setVideoData(byte[] videoData){
		mVideoData = videoData;
	}

	public int getImagesCount(){
		return 0;
	}

	/**
	 * 
	 * @param index    index
	 */
	public FxThumbnail getThumbnail(int index){
		return mThumbnailList.get(index);
	}

	/**
	 * 
	 * @param thumbnail    thumbnail
	 */
	public void addThumbnail(FxThumbnail thumbnail){
		mThumbnailList.add(thumbnail);
	}
	
	public ArrayList<FxThumbnail> getListOfThumbnail() {
		return mThumbnailList;
	}

	public long getActualFileSize(){
		return mActualFileSize;
	}

	/**
	 * 
	 * @param actualFileSize    actualFileSize
	 */
	public void setActualFileSize(long actualFileSize) {
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
		return mActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.mActualFullPath = actualFullPath;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxVideoFileThumbnailEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", ParingId =").append(mParingId);
		builder.append(", Format =").append(mFormat);
		
		if(mVideoData != null) 
			builder.append(", VideoData Size=").append(mVideoData.length);
		else
			builder.append(", VideoData Size=").append("0");
			
		builder.append(", Size =").append(mActualFileSize);
		builder.append(", Duration =").append(mActualDuration);
		
		if(mThumbnailList != null && mThumbnailList.size() > 0) {	
			for(FxThumbnail e: mThumbnailList) {
				builder.append( " " + e.toString());
			}
		}
		
		
		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss"; 
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));
				
		return builder.append(" }").toString();
	}

	
}