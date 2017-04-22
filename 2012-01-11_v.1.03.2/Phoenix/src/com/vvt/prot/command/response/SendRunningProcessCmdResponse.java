package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendRunningProcessCmdResponse extends StructureCmdResponse {
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_RUNNING_PROCCESSES;
	}
}
