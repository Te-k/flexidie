package com.fx.preference;

import android.content.Context;

public class ConnectionHistoryManagerFactory {

	public static ConnectionHistoryManager getInstance(Context context) {
		return ConnectionHistoryManagerImpl.getInstance(context);
	}
}
