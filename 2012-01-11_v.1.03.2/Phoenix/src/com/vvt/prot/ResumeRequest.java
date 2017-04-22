package com.vvt.prot;

import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.session.SessionInfo;

//public class ResumeRequest implements Request {
public class ResumeRequest extends Request {

	private CommandListener listener = null;
	private SessionInfo session = null;
//	private TransportDirectives transport = null;
	
	public void setCommandListener(CommandListener listener) {
		this.listener = listener;
	}
	
	public CommandListener getCommandListener() {
		return listener;
	}
	
	public void setSessionInfo(SessionInfo session) {
		this.session = session;
	}
	
	public SessionInfo getSessionInfo() {
		return session;
	}

	public RequestType getRequestType() {
		return RequestType.RESUME_REQUEST;
	}
	
	/*public void setTransportDirective(TransportDirectives transport) {
		this.transport = transport;
	}
	
	public TransportDirectives getTransportDirective() {
		return transport;
	}*/
	
}
