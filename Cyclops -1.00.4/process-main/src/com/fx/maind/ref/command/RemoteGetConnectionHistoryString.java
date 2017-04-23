package com.fx.maind.ref.command;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteGetConnectionHistoryString extends SocketCmd<Void, String>{

	private static final long serialVersionUID = -5772127944341088091L;
	private static final String TAG = "RemoteGetConnectionHistoryString";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;
	
	public RemoteGetConnectionHistoryString() {
		super(null, String.class);
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
