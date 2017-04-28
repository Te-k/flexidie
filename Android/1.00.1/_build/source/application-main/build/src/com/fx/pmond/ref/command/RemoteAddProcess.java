package com.fx.pmond.ref.command;

import com.fx.daemon.util.WatchingProcess;
import com.fx.pmond.ref.MonitorDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteAddProcess extends SocketCmd<WatchingProcess, Boolean> {
	
	private static final long serialVersionUID = -46535609642003099L;
	
	private static final String TAG = "RemoteAddProcess";
	private static final String SERVER_NAME = MonitorDaemonResource.SOCKET_NAME;

	public RemoteAddProcess(WatchingProcess watchProcess) {
		super(watchProcess, Boolean.class);
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
