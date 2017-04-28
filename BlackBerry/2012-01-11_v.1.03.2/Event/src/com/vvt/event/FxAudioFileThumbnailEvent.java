package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxAudioFileThumbnailEvent extends FxMediaEvent implements Persistable {

	private long actualSize = 0;
	private long actualDuration = 0;
	
	public FxAudioFileThumbnailEvent() {
		setEventType(EventType.AUDIO_FILE_THUMBNAIL);
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
}
