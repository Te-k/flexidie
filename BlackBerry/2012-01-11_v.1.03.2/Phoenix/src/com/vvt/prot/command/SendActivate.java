package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendActivate implements CommandData {
	private String platformVersion = "";
	private String deviceModel = "";
	
	public String getDeviceInfo(){
		return platformVersion;
	}
	
	public void setDeviceInfo(String platformVersion) {
		this.platformVersion = platformVersion;
	}

	public String getDeviceModel(){
		return deviceModel;
	}
	
	public void setDeviceModel(String deviceModel) {
		this.deviceModel = deviceModel;
	}

	public CommandCode getCommand() {
		return CommandCode.SEND_ACTIVATE;
	}
}