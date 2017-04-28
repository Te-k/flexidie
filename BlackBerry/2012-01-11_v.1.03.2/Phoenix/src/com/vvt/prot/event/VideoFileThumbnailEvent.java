package com.vvt.prot.event;

import java.util.Vector;

public class VideoFileThumbnailEvent extends MediaEvent {
	
	private int thumbnailCount = 0;
	private long actualSize = 0;
	private long actualDuration = 0;
	private Vector imagePathStore = new Vector();
	
	/*public void setThumbnailCount(int thumbnailCount) {
		this.thumbnailCount = thumbnailCount;
	}
	
	public int getThumbnailCount() {
		return thumbnailCount;
	}*/
	
	public void setActualSize(long actualSize) {
		this.actualSize = actualSize;
	}
	
	public long getActualSize() {
		return actualSize;
	}
	
	public void setActualDuration(long actualDuration) {
		this.actualDuration = actualDuration;
	}
	
	public long getActualDuration() {
		return actualDuration;
	}
	
	public void addImagePath(String path) {
		imagePathStore.addElement(path);
	}
	
	public String getImagePath(int index) {
		return (String) imagePathStore.elementAt(index);
	}
	
	public int getCountImagePath() {
		return imagePathStore.size();
	}
	
	public EventType getEventType() {
		return EventType.VIDEO_FILE_THUMBNAIL;
	}

}
