package com.fx.maind.ref.command;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.maind.ref.WatchNotificationSettings;
import com.fx.socket.SocketCmd;

public class RemoteGetWatchNotificationSettings extends SocketCmd<Void, WatchNotificationSettings>{

	private static final long serialVersionUID = 2786607807010008196L;
	private static final String TAG = "RemoteGetWatchNotificationSettings";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetWatchNotificationSettings() {
		super(null, WatchNotificationSettings.class);
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
