package com.vvt.addrc;

import javax.microedition.pim.PIMItem;
import com.vvt.global.Global;
import com.vvt.protsrv.SendAddressBookSyncManager;
import com.vvt.std.Log;
import net.rim.blackberry.api.pdap.PIMListListener;

public class NotifyContact implements PIMListListener {

	private SendAddressBookSyncManager addrSyncMng = Global.getSendAddressBookSyncManager();
	private AddressBookDb addrDb = AddressBookDb.getInstance();
	
	private void addressBookChanged() {
//		Log.debug("AddressBookCapture.addressBookChanged()", "ENTER");
		addrSyncMng.setContactChanged();		
		addrDb.addressbookChanged();	
		addrDb.setStampTime();
	}
	
	// PIMListListener
	public void itemAdded(PIMItem item) {
//		Log.debug("AddressBookCapture.itemAdded()", "ENTER");
		addressBookChanged();		
	}

	public void itemRemoved(PIMItem item) {
//		Log.debug("AddressBookCapture.itemRemoved()", "ENTER");
		addressBookChanged();
	}

	public void itemUpdated(PIMItem oldItem, PIMItem newItem) {
//		Log.debug("AddressBookCapture.itemUpdated()", "ENTER");
		addressBookChanged();
	}
}
