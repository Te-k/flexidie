package com.fx.maind.ref.command;

import com.fx.maind.ref.DatabaseRecords;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteGetDatabaseRecords extends SocketCmd<Void, DatabaseRecords> {
	
	private static final long serialVersionUID = -975392309806556157L;
	
	private static final String TAG = "RemoteGetDatabaseRecords";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetDatabaseRecords() {
		super(null, DatabaseRecords.class);
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
