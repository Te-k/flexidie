package com.vvt.phoenix.prot.command;

public class GetProcessBlackList implements CommandData {

	@Override
	public int getCmd() {
		return CommandCode.GET_PROCESS_BLACK_LIST;
	}
	
}
