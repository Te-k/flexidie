package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:25:07
 */
public class FxWallpaperEvent extends FxEvent {

	/**
	 * Members
	 */
	private long mParingId;
	private int mFormat;
	private String m_ActualFullPath;


	@Override
	public FxEventType getEventType(){
		return FxEventType.WALLPAPER;
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

	public int getFormat(){
		return mFormat;
	}

	/**
	 * 
	 * @param type    from MediaType
	 */
	public void setFormat(int type){
		mFormat = type;
	}

	public String getActualFullPath() {
		return m_ActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.m_ActualFullPath = actualFullPath;
	}
	
	
}