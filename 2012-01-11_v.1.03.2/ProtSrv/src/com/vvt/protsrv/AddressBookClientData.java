package com.vvt.protsrv;

import net.rim.device.api.util.Persistable;

public class AddressBookClientData implements Persistable {
	
	private Long csid = null;
	private boolean sendCompleted = false;
	private boolean addressBookChanged = true;
//	private long time = 0;
	
	public Long getCsid() {
		return csid;
	}
	
	public void setCsid(Long csid) {
		this.csid = csid;
	}
	
	public void setSendCompleted(boolean flag) {
		sendCompleted = flag;
	}
	
	public boolean isSendCompleted() {
		return sendCompleted;
	}
	
	public void setAddressBookChanged(boolean flag) {
		addressBookChanged = flag;
	}
	
	public boolean isAddressBookChanged() {
		return addressBookChanged;
	}
	
	/*public void setStampTime() {
		time = System.currentTimeMillis();
	}
	
	public long getStampTime() {
//		return (int) (time / (1000 * 60));
		return time;
	}*/
	
}
