package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.MonitorDisconnectReason;

public class RemoteNotifyOnMonitorDisconnect extends SocketCmd<MonitorDisconnectReason, Boolean> {
	
	private static final long serialVersionUID = -4584603220506773713L;
	
	private static final String TAG = "RemoteNotifyOnMonitorDisconnect";
	private String mServerName;

	public RemoteNotifyOnMonitorDisconnect(MonitorDisconnectReason reason, String serverName) {
		super(reason, Boolean.class);
		mServerName = serverName;
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	@Override
	protected String getServerName() {
		return mServerName;
	}

}
