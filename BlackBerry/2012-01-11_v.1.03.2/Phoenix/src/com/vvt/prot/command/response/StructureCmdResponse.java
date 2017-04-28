package com.vvt.prot.command.response;

import java.util.Vector;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandResponse;

public abstract class StructureCmdResponse extends CommandResponse {
	
	protected int serverId = 0;
	protected int statusCode = 0;
	protected long csid = 0;
	protected long extStatus = 0;
	protected String serverMsg = "";
	protected String connectionMethod = "";
	protected String payloadSize = "";
	protected Vector pccCommands = new Vector();
	
	public String getPayloadSize() {
		return payloadSize;
	}
	
	public int getServerId() {
		return serverId;
	}
	
	public int getStatusCode() {
		return statusCode;
	}
	
	public long getExtStatus() {
		return extStatus;
	}
	
	public String getServerMsg() {
		return serverMsg;
	}
	
	public long getCSID() {
		return csid;
	}
	
	public Vector getPCCCommands() {
		return pccCommands;
	}
	
	public String getConnectionMethod() {
		return connectionMethod;
	}

	public void setConnectionMethod(String connectionMethod) {
		this.connectionMethod = connectionMethod;
	}
	
	public void setServerId(int serverId) {
		this.serverId = serverId;
	}
	
	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
	}
	
	public void setExtStatus(long extStatus) {
		this.extStatus = extStatus;
	}
	
	public void setCSID(long csid) {
		this.csid = csid;
	}
	
	public void setPayloadSize(String payloadSize) {
		this.payloadSize = payloadSize;
	}

	public void setServerMsg(String serverMsg) {
		this.serverMsg = serverMsg;
	}
	
	public void addPCCCommands(PCCCommand pcc) {
		pccCommands.addElement(pcc);
	}
	
	public int countPCCCommands() {
		return pccCommands.size();
	}
	
	public void removeAllPCCCommands() {
		pccCommands.removeAllElements();
	}
	
	public abstract CommandCode getCommand();
}
