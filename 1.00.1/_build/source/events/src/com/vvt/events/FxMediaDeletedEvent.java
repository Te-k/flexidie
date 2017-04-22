package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxMediaDeletedEvent extends FxEvent {

	private String mFileName;
	
	@Override
	public FxEventType getEventType() {
		return FxEventType.DELETED_FILE;
	}
	
	public String getFileName(){
		return mFileName;
	}

	/**
	 * 
	 * @param fileName    fileName
	 */
	public void setFileName(String fileName){
		mFileName = fileName;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxMediaDeletedEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", FileName =").append(getFileName());
		builder.append(", EventTime =").append(super.getEventTime());
		return builder.append(" }").toString();
	}

}
