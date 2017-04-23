package com.fx.maind.ref.command;

import com.fx.maind.ref.AppInfo;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteGetProductInfo extends SocketCmd<Void, AppInfo>{

	private static final long serialVersionUID = -3208679402044904145L;
	
	private static final String TAG = "RemoteGetProductInfo";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetProductInfo() {
		super(null, AppInfo.class);
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
