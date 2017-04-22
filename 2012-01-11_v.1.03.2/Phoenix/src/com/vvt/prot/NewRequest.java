package com.vvt.prot;

import com.vvt.prot.command.TransportDirectives;

//public class NewRequest implements Request {
public class NewRequest extends Request {

	private CommandRequest 		cmdRequest 	= null;
	private long 				csid 		= 0;
	private String 				payloadPath = "";
//	private TransportDirectives transport 	= null;
	
	public void setCommandRequest(CommandRequest cmdRequest) {
		this.cmdRequest = cmdRequest;
	}
	
	public CommandRequest getCommandRequest() {
		return cmdRequest;
	}
	
	public void setClientSessionId(long csid) {
		this.csid = csid;
	}
	
	public long getClientSessionId() {
		return csid;
	}
	
	public void setPayloadPath(String path) {
		payloadPath = path;
	}
	
	public String getPayloadPath() {
		return payloadPath;
	}

	public RequestType getRequestType() {
		return RequestType.NEW_REQUEST;
	}
	
	/*public void setTransportDirective(TransportDirectives transport) {
		this.transport = transport;
	}
	
	public TransportDirectives getTransportDirective() {
		return transport;
	}*/
	
}
