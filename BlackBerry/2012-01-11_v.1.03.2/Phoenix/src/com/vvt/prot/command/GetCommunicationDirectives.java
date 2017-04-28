package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class GetCommunicationDirectives implements CommandData {

	public CommandCode getCommand() {
		return CommandCode.GET_COMMUNICATION_DIRECTIVES;
	}
}
