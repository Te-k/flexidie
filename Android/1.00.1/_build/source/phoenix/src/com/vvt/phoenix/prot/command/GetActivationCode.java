package com.vvt.phoenix.prot.command;

public class GetActivationCode implements CommandData{
	

	@Override
	public int getCmd() {
		return CommandCode.REQUEST_ACTIVATION_CODE;
	}
	
}
