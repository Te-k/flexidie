package com.vvt.prot;

import com.vvt.prot.command.TransportDirectives;

//public interface Request {
public abstract class Request {
	
	public abstract RequestType getRequestType();
	private Priorities 	priority = Priorities.NORMAL;
	private TransportDirectives transport = null;
	
	public Priorities getPriority() {
		return priority;
	}
	
	public TransportDirectives getTransportDirective() {
		return transport;
	}
	
	public void setPriority(Priorities priority) {
		this.priority = priority;
	}
	
	public void setTransportDirective(TransportDirectives transport) {
		this.transport = transport;
	}	
}
