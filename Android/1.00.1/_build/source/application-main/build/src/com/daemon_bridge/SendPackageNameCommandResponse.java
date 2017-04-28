package com.daemon_bridge;

import java.io.Serializable;

public class SendPackageNameCommandResponse extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = 5625267252137153728L;
	private String responseMsg = "";
	
	public SendPackageNameCommandResponse(int responseCode) {
		super(responseCode);
	}
	
	public String getResponseMsg() {
		return this.responseMsg;
	}
	
	public void setResponseMsg(String responseMsg) {
		this.responseMsg = responseMsg;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("SendPackageNameCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", responseMsg =").append(responseMsg);
		return builder.append(" }").toString();		
	}
}
