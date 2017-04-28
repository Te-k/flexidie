package com.vvt.phoenix.prot.command;

public class GetTime implements CommandData{
	
	

	@Override
	public int getCmd() {
		return CommandCode.GET_TIME;
	}
	
	

}
