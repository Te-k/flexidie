package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class GetActivationCodeResponse extends ResponseData {
	
	//Members
	private String mActivationCode;

	@Override
	public int getCmdEcho() {
		return CommandCode.REQUEST_ACTIVATION_CODE;
	}
	
	public String getActivationCode(){
		return mActivationCode;
	}
	public void setActivationCode(String code){
		mActivationCode = code;
	}

}
