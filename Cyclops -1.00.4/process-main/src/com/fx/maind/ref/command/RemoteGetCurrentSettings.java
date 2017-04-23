package com.fx.maind.ref.command;

import com.fx.maind.ref.CurrentSettings;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteGetCurrentSettings extends SocketCmd<Void, CurrentSettings>{

	private static final long serialVersionUID = 5092142211055446830L;
	private static final String TAG = "RemoteGetCurrentSettings";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetCurrentSettings() {
		super(null, CurrentSettings.class);
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
