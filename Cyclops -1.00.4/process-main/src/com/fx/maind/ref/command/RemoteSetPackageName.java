package com.fx.maind.ref.command;


import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteSetPackageName extends SocketCmd<String, Boolean> {

	private static final long serialVersionUID = 6646499192286046528L;
	private static final String TAG = "RemoteSetPackageName";
	
	public RemoteSetPackageName(String packageName) {
		super(packageName, Boolean.class);
	}
	
	@Override
	protected String getTag() {
		return TAG;
	}

	@Override
	protected String getServerName() {
		return MainDaemonResource.SOCKET_NAME;
	}
}
