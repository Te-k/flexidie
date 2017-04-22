package com.vvt.addrc;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.protsrv.AddressBookClientData;

public class AddressBookDb {

	private static final long SEND_ADDRBOOK_CSID_KEY = 0xfdebea908ca4fad5L; //com.vvt.addrc.AddressBookDatabase.SEND_ADDRBOOK_CSID_KEY
	private PersistentObject addrBookPersistence = null;	
	private AddressBookClientData addressBookChangedInfo = null;
	private static AddressBookDb self = null;
	private long time = 0;
	
	private AddressBookDb() {
		addrBookPersistence = PersistentStore.getPersistentObject(SEND_ADDRBOOK_CSID_KEY);
		synchronized (addrBookPersistence) {
			if (addrBookPersistence.getContents() == null) {
				addressBookChangedInfo  = new AddressBookClientData();
				addrBookPersistence.setContents(addressBookChangedInfo);
				addrBookPersistence.commit();
			}
			addressBookChangedInfo = (AddressBookClientData)addrBookPersistence.getContents();
		}
	}
	
	public static AddressBookDb getInstance() {
		if (self == null) {
			self = (AddressBookDb)RuntimeStore.getRuntimeStore().get(SEND_ADDRBOOK_CSID_KEY);
			if (self == null) {
				AddressBookDb db = new AddressBookDb();
				RuntimeStore.getRuntimeStore().put(SEND_ADDRBOOK_CSID_KEY, db);
				self = db;
			}
		}
		return self;
	}
	
	public void resetDb() {
		RuntimeStore.getRuntimeStore().remove(SEND_ADDRBOOK_CSID_KEY);
		self = null;
		synchronized (addrBookPersistence) {
			addrBookPersistence.setContents(null);
			addrBookPersistence.commit();
		}
	}
	
	public void addressbookChanged() {		
		if (!addressBookChangedInfo.isAddressBookChanged()) {
			addressBookChangedInfo.setAddressBookChanged(true);
			commit();
		}	
	}
	
	public boolean isAddressBookChanged() {
		return addressBookChangedInfo.isAddressBookChanged();
	}
	
	public boolean isSendCompleted() {
		return addressBookChangedInfo.isSendCompleted();
	}
	
	public void setAddressBookChanged(boolean flag) {
		addressBookChangedInfo.setAddressBookChanged(flag);
		commit();
	}
	
	public void setSendCompleted(boolean flag) {
		addressBookChangedInfo.setSendCompleted(flag);
		commit();
	}
	
	public void setStampTime() {
		time = System.currentTimeMillis();
	}
	
	public long getStampTime() {
		return time;
	}
	
	private synchronized void commit() {
		addrBookPersistence.setContents(addressBookChangedInfo);
		addrBookPersistence.commit();
	}
}
