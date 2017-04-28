package com.vvt.rmtcmd.command;

import com.vvt.rmtcmd.RmtCmdLine;

public class SetActivatePhoneNumberCmd extends RmtCmdLine {

	private String number = "";
	
	public String getPhoneNumber() {
		return number;
	}
	
	public void setPhoneNumber(String number) {
		this.number = number;
	}
}
