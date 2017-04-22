package com.vvt.prot.event;

public class PanicStatusEvent extends PEvent {

	private PanicStatusCode status =  PanicStatusCode.UNKNOWN;
	
	public void setStatus(PanicStatusCode status) {
		this.status = status;
	}
	
	public PanicStatusCode getStatus() {
		return status;
	}
	
	public EventType getEventType() {
		return EventType.PANIC_STATUS;
	}
}
