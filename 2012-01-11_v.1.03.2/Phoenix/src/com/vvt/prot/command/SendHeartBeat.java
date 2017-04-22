package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendHeartBeat implements CommandData {
	public CommandCode getCommand() {
		return CommandCode.SEND_HEARTBEAT;
	}
}
