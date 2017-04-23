package com.fx.maind.ref.command;

import com.fx.maind.ref.ActivationResponse;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteDeactivateProduct extends SocketCmd<String, ActivationResponse>{

	private static final long serialVersionUID = -1513355675364499224L;
	
	private static final String TAG = "RemoteDeactivateProduct";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;
	
	public RemoteDeactivateProduct() {
		super(null, ActivationResponse.class);
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
