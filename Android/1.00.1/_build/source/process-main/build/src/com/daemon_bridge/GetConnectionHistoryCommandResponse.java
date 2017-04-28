package com.daemon_bridge;

import java.io.Serializable;

public class GetConnectionHistoryCommandResponse extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = 7758051175644029501L;
	
	private String mConnectionHistory = null;
	
	public GetConnectionHistoryCommandResponse(int responseCode) {
		super(responseCode);
	}
	
	public String getConnectionHistory() {
		return this.mConnectionHistory;
	}
	
	public void setConnectionHistory(String connectionHistory) {
		this.mConnectionHistory = connectionHistory;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("GetConnectionHistoryCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", ConnectionHistory =").append(mConnectionHistory);
		return builder.append(" }").toString();		
	}
}
