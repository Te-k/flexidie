package com.vvt.protsrv.addr;

import net.rim.blackberry.api.pdap.BlackBerryContact;

public class ContactInfo {

	private long serverId = 0;
	private String clientId = "";
	private BlackBerryContact contact = null;
	
	public void setContact(BlackBerryContact contact) {
		this.contact = contact;
	}
	
	public BlackBerryContact getContact() {
		return contact;
	}
	
	public void setClientId(String clientId) {
		this.clientId = clientId;
	}
	
	public String getClientId() {
		return clientId;
	}
		
	public void setServerId(long serverId) {
		this.serverId = serverId;
	}
	
	public long getServerId() {
		return serverId;
	}
}
