package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class UnknownResponse extends ResponseData {

	@Override
	public int getCmdEcho() {
		return CommandCode.UNKNOWN_OR_RASK;
	}

}
