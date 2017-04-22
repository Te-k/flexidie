package com.fx.socket;

import java.io.Serializable;

import com.fx.socket.RemoteSetSync.SyncData;

public class RemoteSetSync extends SocketCmd<SyncData, Boolean> {

	private static final long serialVersionUID = 307412736898318237L;
	
	private static final String TAG = "RemoteSetSync";
	private static String mServerName;

	public RemoteSetSync(String serverName, SyncData data) {
		super(data, Boolean.class);
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
	
	public static class SyncData implements Serializable {
		
		private static final long serialVersionUID = 2693185931577984454L;
		
		private String clientPackage;
		private boolean isSync;
		
		public String getClientPackage() {
			return clientPackage;
		}
		public void setClientPackage(String clientPackage) {
			this.clientPackage = clientPackage;
		}
		public boolean isSync() {
			return isSync;
		}
		public void setSync(boolean isSync) {
			this.isSync = isSync;
		}
	}

}