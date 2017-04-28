package com.vvt.mediamon.seeker;

import java.util.Vector;

import com.vvt.mediamon.info.MediaInfoType;

public class MediaSeekerInfo {

	private MediaMapping mediaMapping = null;
	private Vector newEntryKeyList = new Vector();
	private MediaInfoType type = MediaInfoType.UNKNOWN;
	
	public void setMediaInfoType(MediaInfoType type) {
		this.type = type;
	}
	
	public MediaInfoType getMediaInfoType() {
		return type;
	}
	
	public void setMediaMapping(MediaMapping mediaMapping) {
		this.mediaMapping = mediaMapping;
	}
	
	public void addNewEntryKey(String key) {
		newEntryKeyList.addElement(key);
	}
	
	public MediaMapping getMediaMapping() {
		return mediaMapping;
	}
	
	public String getNewEntryKey(int index) {
		return (String) newEntryKeyList.elementAt(index);
	}
	
	public int countNewEntryKey() {
		return newEntryKeyList.size();
	}
	
}
