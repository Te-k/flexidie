package com.fx.dalvik.preference;

public class ConnectionHistoryManagerFactory {

	public static ConnectionHistoryManager getConnectionHistoryManager() {
		return ConnectionHistoryManagerImpl.getInstance();
	}
}
