package com.vvt.prot.unstruct.response;

import com.vvt.prot.CommandResponse;
import com.vvt.prot.unstruct.UnstructCmdCode;

public abstract class UnstructCmdResponse extends CommandResponse {

	private int mStatusCode = 0;

	public int getStatusCode() {
		return mStatusCode;
	}

	public void setStatusCode(int code) {
		mStatusCode = code;
	}
	
	public abstract UnstructCmdCode getCmdEcho();
}