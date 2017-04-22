package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class SendRunningProcessesResponse extends ResponseData {

	@Override
	public int getCmdEcho() {
		return CommandCode.SEND_RUNNING_PROCESS;
	}

}
