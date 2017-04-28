package com.vvt.phoenix.prot.command.response;

import com.vvt.phoenix.prot.command.CommandCode;

public class GetConfigurationResponse extends ResponseData {
	
	//Members
	private byte[] mMD5;
	private int mConfigId;

	@Override
	public int getCmdEcho() {
		return CommandCode.REQUEST_CONFIGURATION;
	}
	
	public byte[] getMD5(){
		return mMD5;
	}
	public void setMD5(byte[] MD5){
		mMD5 = MD5;
	}
	
	public int getConfigId(){
		return mConfigId;
	}
	public void setConfigId(int configId){
		mConfigId = configId;
	}

}
 