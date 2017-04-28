package com.fx.maind.ref.command;

import com.fx.maind.ref.ActivationResponse;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;

public class RemoteActivateProduct extends SocketCmd<String, ActivationResponse>{

	private static final long serialVersionUID = 5418394579138828889L;
	
	private static final String TAG = "RemoteActivateProduct";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;
	
	public RemoteActivateProduct(String activationUrl) {
		super(activationUrl, ActivationResponse.class);
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
