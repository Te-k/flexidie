package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class SendEventsResponse extends ResponseData{

	@Override
	public int getCmdEcho() {
		return CommandCode.SEND_EVENT;
	}

}
