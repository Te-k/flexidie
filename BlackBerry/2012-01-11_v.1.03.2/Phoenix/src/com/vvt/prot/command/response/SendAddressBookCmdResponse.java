package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendAddressBookCmdResponse extends StructureCmdResponse {
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_ADDRESS_BOOK;
	}
}
