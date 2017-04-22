package com.vvt.events;

import java.util.Date;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxPanicStatusEvent extends FxEvent{

	private boolean status;
	
	@Override
	public FxEventType getEventType() {
		return FxEventType.PANIC_STATUS;
	}

	public boolean getStatus() {
		return status;
	}

	public void setStatus(boolean status) {
		this.status = status;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxPanicGpsEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", status =").append(getStatus());

		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss";
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));

		return builder.append(" }").toString();
	}
	
}
