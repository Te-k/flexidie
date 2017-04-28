package com.fx.preference;

import android.content.Context;

public class SpyInfoManagerFactory {
	
	public static SpyInfoManager getSpyInfoManager(Context context) {
//		return new SpyInfoManagerMockImpl(context);
		return SpyInfoManagerImpl.getInstance(context);
	}

}
