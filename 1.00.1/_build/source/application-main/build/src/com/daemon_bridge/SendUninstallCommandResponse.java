package com.daemon_bridge;

import java.io.Serializable;

public class SendUninstallCommandResponse extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = 4528451523903446414L;
	private String responseMsg = "";
	
	public SendUninstallCommandResponse(int responseCode) {
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
		builder.append("SendUninstallCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", responseMsg =").append(responseMsg);
		return builder.append(" }").toString();		
	}
}
