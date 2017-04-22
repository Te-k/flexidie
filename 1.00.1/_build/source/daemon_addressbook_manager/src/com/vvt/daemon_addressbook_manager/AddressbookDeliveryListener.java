package com.vvt.daemon_addressbook_manager;

public interface AddressbookDeliveryListener {
	public void onSuccess(); 
	public void onError(int statusCode, String error);
}
