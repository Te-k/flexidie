package com.vvt.daemon_addressbook_manager;

import java.util.List;

import com.vvt.base.FxAddressbookMode;
import com.vvt.exceptions.FxNullNotAllowedException;

/**
 * @author Aruna
 * @version 1.0
 * @created 07-Oct-2011 03:22:36
 */
public interface AddressbookManager {
	public void startMonitor() throws FxNullNotAllowedException;

	public void startRestricted() throws FxNullNotAllowedException;

	public void stop()  throws FxNullNotAllowedException;

	public List<ApprovedContact> getApprovedContacts();

	public void getAddressbook(AddressbookDeliveryListener listener) throws FxNullNotAllowedException;

	public void sendAddressbook(AddressbookDeliveryListener listener, int delay);
	
	public void setMode(FxAddressbookMode mode);
	
	public FxAddressbookMode getMode();
	
	public int getAddressBookCount();
}