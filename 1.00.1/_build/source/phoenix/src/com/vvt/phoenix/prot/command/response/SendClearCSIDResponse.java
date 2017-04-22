package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class SendClearCSIDResponse extends ResponseData{

	@Override
	public int getCmdEcho() {
		return CommandCode.CLEARSID;
	}

}
