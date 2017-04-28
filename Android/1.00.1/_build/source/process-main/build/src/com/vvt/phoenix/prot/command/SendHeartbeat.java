package com.vvt.phoenix.prot.command;


public class SendHeartbeat implements CommandData {

	@Override
	public int getCmd() {
		return CommandCode.SEND_HEARTBEAT;
	}

}
