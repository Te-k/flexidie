package com.fx.maind.ref.command;

import com.fx.maind.ref.MainDaemonResource;
import com.fx.socket.SocketCmd;
import com.vvt.license.LicenseStatus;

public class RemoteGetLicenseStatus extends SocketCmd<Void, LicenseStatus>{

	private static final long serialVersionUID = -6759395866445785173L;
	
	private static final String TAG = "RemoteGetLicenseStatus";
	private static final String SERVER_NAME = MainDaemonResource.SOCKET_NAME;

	public RemoteGetLicenseStatus() {
		super(null, LicenseStatus.class);
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
