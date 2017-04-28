package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class SendAddressBookForApprovalResponse extends ResponseData{

	@Override
	public int getCmdEcho() {
		return CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL;
	}

}
