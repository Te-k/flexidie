package com.vvt.mediamon.seeker;

import java.util.Hashtable;
import com.vvt.mediamon.info.MediaInfo;
import net.rim.device.api.util.Persistable;

public class MediaMapping implements Persistable {

	private Hashtable actualPathMap = null;
	private Hashtable paringIdMap = null;
	private int paringId = 0;
	
	public MediaMapping() {
		actualPathMap = new Hashtable();
		paringIdMap = new Hashtable();
	}
	
	public void add(String actualPath, MediaInfo mediaInfo) {
		actualPathMap.put(actualPath, mediaInfo);
	}
	
	public void add(int paringId, MediaInfo mediaInfo) {
		paringIdMap.put(new Integer(paringId), mediaInfo);		
	}
	
	public MediaInfo get(String actualPath) {
		return (MediaInfo) actualPathMap.get(actualPath);
	}
	
	public MediaInfo get(int paringId) {
		return (MediaInfo) paringIdMap.get(new Integer(paringId));
	}
	
	public Hashtable getActualPathMap() {
		return actualPathMap;
	}
	
	public Hashtable getParingIdMap() {
		return paringIdMap;
	}
	
	public int getNextParingId() {
		if (paringId < Integer.MAX_VALUE) {
			++paringId;
		} else {
			paringId = 1;
		}
		return paringId;
	}
}
