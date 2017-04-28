package com.vvt.phoenix.prot.event;

public class WallpaperEvent extends Event{

	//Members
	private long mParingId;
	private int mFormat;
	private String mFilePath;
	
	@Override
	public int getEventType() {
		return EventType.WALLPAPER;
	}
	
	public long getParingId(){
		return mParingId;
	}
	public void setParingId(long id){
		mParingId = id;
	}
	
	public int getFormat(){
		return mFormat;
	}
	/**
	 * @param type from MediaType
	 */
	public void setFormat(int type){
		mFormat = type;
	}
	
	public String getFilePath(){
		return mFilePath;
	}
	public void setFilePath(String absolutePath){
		mFilePath = absolutePath;
	}

}
