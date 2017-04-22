package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendClearCSIDCmdResponse extends StructureCmdResponse {
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_CLEARCSID;
	}
}
