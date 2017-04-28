package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class GetActivationCodeCmdResponse extends StructureCmdResponse {
	
	private String activationCode = "";
	
	public String getActivationCode() {
		return activationCode;
	}

	public void setActivationCode(String activationCode) {
		this.activationCode = activationCode;
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_ACTIVATION_CODE;
	}
}
