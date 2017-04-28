package com.vvt.prot.event;

public class AudioFileThumbnailEvent extends MediaEvent {

	private long actualSize = 0;
	private long actualDuration = 0;
	
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
	
	public EventType getEventType() {
		return EventType.AUDIO_FILE_THUMBNAIL;
	}

}
