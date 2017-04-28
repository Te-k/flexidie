package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendEventCmdResponse extends StructureCmdResponse {
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_EVENTS;
	}
}
