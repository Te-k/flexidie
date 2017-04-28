package com.vvt.android.syncmanager.utils;

import android.content.res.Resources;

public final class ResourcesWrapper {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
		
	private static final String TAG = "ResourcesWrapper";
	
	private static Resources resources = null;
	
	/**
	  * SingletonHolder is loaded on the first execution of DaemonScheduler.getInstance() 
	  * 	or the first access to DaemonScheduler.INSTANCE, not before. 
	  * 
	  * This solution is thread-safe without requiring special language constructs.	
	  */
	private static class SingletonHolder { private static final ResourcesWrapper INSTANCE = new ResourcesWrapper(); }
	
	private ResourcesWrapper() {}

//------------------------------------------------------------------------------------------------------------------------
// PUBLIC API
//------------------------------------------------------------------------------------------------------------------------
		 
	public static ResourcesWrapper getInstance() {
		
		if (resources == null) throw new RuntimeException(TAG + ".getInstance # Programming Error: Object accessed prior to proper initialization");
		return SingletonHolder.INSTANCE; 
	}
	
	public static void setResources(Resources aResources) { resources = aResources; }
	
	public String get(int aResourceLookupId) { 
		
		CharSequence aCharSequence = resources.getText(aResourceLookupId);
		return aCharSequence != null ? aCharSequence.toString() : "";
	}
}
