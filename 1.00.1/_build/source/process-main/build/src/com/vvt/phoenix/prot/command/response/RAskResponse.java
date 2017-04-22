package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class RAskResponse extends ResponseData {

	// Members
	private int mBytesReceived;
	
	@Override
	public int getCmdEcho() {
		return CommandCode.UNKNOWN_OR_RASK;	// RAsk CMD_ECHO is 0
	}
	
	public int getNumberOfBytesReceived(){
		return mBytesReceived;
	}
	public void setNumberOfBytesReceived(int n){
		mBytesReceived = n;
	}

}
