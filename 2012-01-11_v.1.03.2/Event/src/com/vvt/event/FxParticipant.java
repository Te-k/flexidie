package com.vvt.event;

import net.rim.device.api.util.Persistable;

public class FxParticipant implements Persistable {
	
	private String uid = "";
	private String name = "";
	
	public String getUid() {
		return uid;
	}
	
	public String getName() {
		return name;
	}
	
	public void setUid(String uid) {
		this.uid = uid;
	}

	public void setName(String name) {
		this.name = name;
	}
}
