package com.fx.socket;

import com.fx.socket.SocketCmd;

public class RemoteCheckAlive extends SocketCmd<String, Boolean> {
	
	private static final long serialVersionUID = -4924766994872831800L;

	private static final String TAG = "RemoteCheckAlive";
	private static String mServerName;

	public RemoteCheckAlive(String serverName) {
		super(null, Boolean.class);
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
