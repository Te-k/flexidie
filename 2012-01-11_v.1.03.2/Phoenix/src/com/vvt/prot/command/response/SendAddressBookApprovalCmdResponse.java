package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendAddressBookApprovalCmdResponse extends StructureCmdResponse {

	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL;
	}
}
