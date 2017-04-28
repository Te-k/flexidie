package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:12:44
 */
public class FxWallPaperThumbnailEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private FxMediaType mFormat;
	private long mActualFileSize;
	private String m_ActualFullPath;
	private String m_ThumbnailFullPath;
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.WALLPAPER_THUMBNAIL;
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

	public String getActualFullPath() {
		return m_ActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.m_ActualFullPath = actualFullPath;
	}

	public String getThumbnailFullPath() {
		return m_ThumbnailFullPath;
	}

	public void setThumbnailFullPath(String thumbnailFullPath) {
		this.m_ThumbnailFullPath = thumbnailFullPath;
	}

	public long getActualSize(){
		return mActualFileSize;
	}

	/**
	 * 
	 * @param actualFileSize    actualFileSize
	 */
	public void setActualSize(long actualFileSize){
		mActualFileSize = actualFileSize;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("FxWallPaperThumbnailEvent {");
		builder.append(" mParingId =").append(mParingId);
		builder.append(", mFormat =").append(mFormat);
		builder.append(", mActualFileSize =").append(mActualFileSize);
		builder.append(", m_ThumbnailFullPath =").append(m_ThumbnailFullPath);
		builder.append(", m_ActualFullPath =").append(m_ActualFullPath);
		return builder.append(" }").toString();
	}
 }