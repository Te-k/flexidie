package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class SendActivateCmdResponse extends StructureCmdResponse {
	
	private byte[] md5 = null;
	private int configID = 0;
	
	public byte[] getMd5() {
		return md5;
	}

	public int getConfigID() {
		return configID;
	}

	public void setMd5(byte[] md5) {
		this.md5 = md5;
	}

	public void setConfigID(int configID) {
		this.configID = configID;
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.SEND_ACTIVATE;
	}
}
