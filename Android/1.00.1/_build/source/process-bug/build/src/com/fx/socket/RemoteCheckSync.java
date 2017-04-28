package com.fx.socket;

public class RemoteCheckSync extends SocketCmd<String, Boolean> {

	private static final long serialVersionUID = 8097922490892284490L;
	
	private static final String TAG = "RemoteCheckSync";
	private static String mServerName;

	public RemoteCheckSync(String serverName, String clientPkg) {
		super(clientPkg, Boolean.class);
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
