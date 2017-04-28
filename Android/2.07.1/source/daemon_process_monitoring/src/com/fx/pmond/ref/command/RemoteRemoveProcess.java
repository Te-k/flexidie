package com.fx.pmond.ref.command;

import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteRemoveProcess extends SocketCmd<String, Boolean> {
	
	private static final long serialVersionUID = 512394972308336158L;
	
	private static final String TAG = "RemoteRemoveProcess";
	private static final String SERVER_NAME = MonitorDaemonResource.SOCKET_NAME;

	public RemoteRemoveProcess(String processName) {
		super(processName, Boolean.class);
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
