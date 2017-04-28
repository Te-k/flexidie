package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class GetActivationCode implements CommandData {
	public CommandCode getCommand() {
		return CommandCode.GET_ACTIVATION_CODE;
	}
}
