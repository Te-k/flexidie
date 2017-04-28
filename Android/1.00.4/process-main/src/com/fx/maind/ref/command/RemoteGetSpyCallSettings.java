package com.fx.maind.ref.command;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.maind.ref.SpyCallSettings;
import com.fx.socket.SocketCmd;

public class RemoteGetSpyCallSettings extends SocketCmd<Void, SpyCallSettings>{

	private static final long serialVersionUID = 2786607807010008196L;
	private static final String TAG = "RemoteGetSpyCallSettings";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetSpyCallSettings() {
		super(null, SpyCallSettings.class);
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
