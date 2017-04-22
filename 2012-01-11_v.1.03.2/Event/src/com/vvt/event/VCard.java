package com.vvt.event;

import net.rim.device.api.util.Persistable;

public class VCard implements Persistable {
	
	private String vcardData = null;
	
	public void setVcardData(String vcardData) {
		this.vcardData = vcardData;
	}

	public String getVcardData() {
		return vcardData;
	}
	
	public long lenghtOfVCardData() {
		return vcardData.length();
	}
}
