package com.vvt.phoenix.prot.command;


public class SendActivate implements CommandData {

	// Fields
	private String mDeviceInfo;
	private String mDeviceModel;

	@Override
	public int getCmd() {
		return CommandCode.SEND_ACTIVATE;
	}
	
	public String getDeviceInfo(){
		return mDeviceInfo;
	}
	public void setDeviceInfo(String info){
		mDeviceInfo = info;
	}
	
	public String getDeviceModel(){
		return mDeviceModel;
	}
	public void setDeviceModel(String model){
		mDeviceModel = model;
	}
	
}
