package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendRAskCmdResponse extends StructureCmdResponse {
	private long numberOfBytes = 0;
	
	public long getNumberOfBytes() {
		return numberOfBytes;
	}
	
	public void setNumberOfBytes(long numberOfBytes) {
		this.numberOfBytes = numberOfBytes;
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.UNKNOWN;
	}
}
