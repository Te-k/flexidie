package com.vvt.phoenix.prot.command;

public class GetProcessWhiteList implements CommandData{


	@Override
	public int getCmd() {
		return CommandCode.GET_PROCESS_WHITE_LIST;
	}
	
}
