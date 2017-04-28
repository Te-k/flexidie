package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendClearCSID implements CommandData {
	private long sessionId = 0;
	
	public void setSessionId(long sessionId) {
		this.sessionId = sessionId;
	}

	public long getSessionId() {
		return sessionId;
	}
	
	public CommandCode getCommand() {
		return CommandCode.SEND_CLEARCSID;
	}	
}