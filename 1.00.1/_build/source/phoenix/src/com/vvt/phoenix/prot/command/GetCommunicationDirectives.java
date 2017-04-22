package com.vvt.phoenix.prot.command;


public class GetCommunicationDirectives implements CommandData{
	
	

	@Override
	public int getCmd() {
		return CommandCode.GET_COMMU_MANAGER_SETTINGS;
	}
	
	

}
