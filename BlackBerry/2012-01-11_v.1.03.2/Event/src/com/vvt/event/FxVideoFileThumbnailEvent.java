package com.vvt.event;

import java.util.Vector;
import com.vvt.event.constant.EventType;
import net.rim.device.api.util.Persistable;

public class FxVideoFileThumbnailEvent extends FxMediaEvent implements Persistable {
	
	private long actualSize = 0;
	private long actualDuration = 0;
	private Vector imagePathStore = new Vector();
	
	public FxVideoFileThumbnailEvent() {
		setEventType(EventType.VIDEO_FILE_THUMBNAIL);
	}
	
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

}
