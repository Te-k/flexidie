package com.vvt.prot.event;

import com.vvt.prot.command.VCardSummaryFields;

public class VCard {
	private long serverId = 0;
	private String clientId = "";
	private int status;
	private VCardSummaryFields vCardSummary;
	private byte[] vcardData;
	
	
	public void setApprovalStatus(int status) {
		this.status = status;
	}
	
	public int getApprovalStatus() {
		return status;
	}
	
	public void addVCardSummary(VCardSummaryFields vCardSummary) {
		this.vCardSummary = vCardSummary;
	}
	
	public VCardSummaryFields getVCardSummary() {
		return vCardSummary;
	}
	
	public void setServerId(long serverId) {
		this.serverId = serverId;
	}
	
	public long getServerId() {
		return serverId;
	}
	
	public void setClientId(String clientId) {
		this.clientId = clientId;
	}
	
	public String getClientId() {
		return clientId;
	}
	
	public void setVCardData(byte[] vcardData) {
		this.vcardData = vcardData;
	}
	
	public byte[] getVCardData() {
		return vcardData;
	}
	
}
