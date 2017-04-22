package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class UnknownCmdResponse extends StructureCmdResponse {
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.UNKNOWN;
	}
}
