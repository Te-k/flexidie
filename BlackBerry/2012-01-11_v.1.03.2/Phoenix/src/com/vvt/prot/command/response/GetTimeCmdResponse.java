package com.vvt.prot.command.response;

import com.vvt.prot.CommandCode;

public class GetTimeCmdResponse extends StructureCmdResponse {
	
	private String gmtTime = "";
	private String timezone = "";
	private int representation = 0;

	public String getGMTTime() {
		return gmtTime;
	}

	public String getTimezone() {
		return timezone;
	}

	public int getRepresentation() {
		return representation;
	}

	public void setGMTTime(String gmtTime) {
		this.gmtTime = gmtTime;
	}

	public void setTimezone(String timezone) {
		this.timezone = timezone;
	}

	public void setRepresentation(int representation) {
		this.representation = representation;
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_TIME;
	}
}
