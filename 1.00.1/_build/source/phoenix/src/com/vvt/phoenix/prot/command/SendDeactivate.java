package com.vvt.phoenix.prot.command;


public class SendDeactivate implements CommandData {

	
	@Override
	public int getCmd() {
		return CommandCode.SEND_DEACTIVATE;
	}

}
