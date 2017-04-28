package com.vvt.phoenix.prot.command;


public class GetConfiguration implements CommandData {
	
	

	@Override
	public int getCmd() {
		return CommandCode.REQUEST_CONFIGURATION;
	}
	
	
	

}
