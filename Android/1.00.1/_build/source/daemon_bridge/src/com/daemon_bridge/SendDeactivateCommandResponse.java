package com.daemon_bridge;

import java.io.Serializable;

public class SendDeactivateCommandResponse extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = -8362315888483276758L;
	private String responseMsg = "";
	
	public SendDeactivateCommandResponse(int responseCode) {
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
		builder.append("SendDeactivateCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", responseMsg =").append(responseMsg);
		return builder.append(" }").toString();		
	}
}
