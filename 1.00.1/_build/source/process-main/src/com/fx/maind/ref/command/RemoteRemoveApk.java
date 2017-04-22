package com.fx.maind.ref.command;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteRemoveApk extends SocketCmd<String, Boolean> {

	private static final long serialVersionUID = 7656641223824180831L;
	
	private static final String TAG = "RemoteRemoveApk";
	private String mPackageName;
	
	public RemoteRemoveApk() {
		super(null, Boolean.class);
	}
	
	public void setPackageName(String packageName) {
		mPackageName = packageName;
	}
	
	public String getPackageName() {
		return mPackageName;
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
